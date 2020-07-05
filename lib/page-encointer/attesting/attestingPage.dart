import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:polka_wallet/common/components/infoItem.dart';
import 'package:polka_wallet/common/components/passwordInputDialog.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page-encointer/attesting/qrCode.dart';
import 'package:polka_wallet/page/account/txConfirmPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestationState.dart';
import 'package:polka_wallet/store/encointer/types/attestation.dart';
import 'package:polka_wallet/store/encointer/types/claimOfAttendance.dart';
import 'package:polka_wallet/utils/i18n/index.dart';
import 'package:polka_wallet/page-encointer/attesting/meetupPage.dart';
import 'package:polka_wallet/page-encointer/common/CeremonyOverviewPanel.dart';
import 'package:polka_wallet/page-encointer/attesting/confirmAttendeesDialog.dart';

class AttestingPage extends StatefulWidget {
  AttestingPage(this.store);

  static const String route = '/encointer/attesting';
  final AppStore store;

  @override
  _AttestingPageState createState() => _AttestingPageState(store);
}

class _AttestingPageState extends State<AttestingPage> {
  _AttestingPageState(this.store);

  final AppStore store;

  @observable
  var _amountAttendees;

  @action
  setAmountAttendees(amount) {
    _amountAttendees = amount;
  }

  String _tab = 'DOT';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startMeetup(BuildContext context) async {
    var amount = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ConfirmAttendeesDialog()));
    setAmountAttendees(amount);
    var claimHex =
        await webApi.encointer.getClaimOfAttendance(_amountAttendees);
    print("Claim: " + claimHex);

    var meetupRegistry = await webApi.encointer.fetchMeetupRegistry();
/*    var meetupRegistry = List.filled(amount, '0x44495e0e8733d0b65ea1333c8bf7f4c54dc9f580b38aaadc3d771c771fb70260');
    meetupRegistry[0] = '0x11195e0e8733d0b65ea1333c8bf7f4c54dc9f580b38aaadc3d771c771fb70260';
    meetupRegistry[1] = store.account.currentAccountPubKey;
    meetupRegistry[2] = '0x22295e0e8733d0b65ea1333c8bf7f4c54dc9f580b38aaadc3d771c771fb70260';
    meetupRegistry[3] = '0x33395e0e8733d0b65ea1333c8bf7f4c54dc9f580b38aaadc3d771c771fb70260';
    meetupRegistry[4] = '0x44495e0e8733d0b65ea1333c8bf7f4c54dc9f580b38aaadc3d771c771fb70260';
*/
    store.encointer.attestations = _buildAttestationStateMap(meetupRegistry);

    var args = {'claim': claimHex, 'confirmedParticipants': amount};

//    _showPasswordDialog(context, claimHex);
    Navigator.pushNamed(context, MeetupPage.route, arguments: args);
  }

  Map<int, AttestationState> _buildAttestationStateMap(List<dynamic> pubKeys) {
    final map = Map<int, AttestationState>();
    pubKeys.asMap().forEach((i, key) => !(key == store.account.currentAddress)
            ? map.putIfAbsent(i, () => AttestationState(key))
            : store.encointer.myMeetupRegistryIndex =
                i // track our index as it defines if we must show our qr-code first
        );

    print("My index in meetup registry is " +
        store.encointer.myMeetupRegistryIndex.toString());
    return map;
  }

  Future<void> _submitClaim(
      BuildContext context, String claimHex, String password) async {
    var att =
        await webApi.encointer.attestClaimOfAttendance(claimHex, password);
    print("att: " + att.toString());

//    var args = {
//      "title": 'register_attestations',
//      "txInfo": {
//        "module": 'encointerCeremonies',
//        "call": 'registerAttestations',
//      },
//      "detail": jsonEncode({
//        "attestations": [att],
//      }),
//      "params": [
//        [att], // we usually supply a list of attestations
//      ],
//      'onFinish': (BuildContext txPageContext, Map res) {
//        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
//      }
//    };
//    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }

  Future<void> _showPasswordDialog(
      BuildContext context, String claimHex) async {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          title: Text(I18n.of(context).home['unlock']),
          onOk: (password) => _submitClaim(context, claimHex, password),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;
    final int decimals = encointer_token_decimals;
    return SafeArea(
        child: Container(
            width: double.infinity,
            child: RoundedCard(
              margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
              padding: EdgeInsets.all(8),
              child: Column(children: <Widget>[
                Observer(
                    builder: (_) => _reportAttestationsCount(
                        context, store.encointer.attestations)),
                FutureBuilder<int>(
                    future: webApi.encointer.fetchMeetupIndex(),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasData) {
                        if (store.encointer.meetupIndex == 0) {
                          return Text("you are not assigned to a meetup");
                        }
                        return RoundedButton(
                            text: "start meetup",
                            onPressed: () => _startMeetup(
                                context) // for testing always allow sending
                            );
                      } else {
                        return CupertinoActivityIndicator();
                      }
                    }),
              ]),
            )));
  }

  Widget _reportAttestationsCount(
      BuildContext context, Map<int, AttestationState> attestations) {
    var count = attestations
        .map((key, value) => MapEntry(key, value.yourAttestation))
        .values
        .where((x) => x != null)
        .toList()
        .length;
    return Column(children: <Widget>[
      Text("you have been attested by " + count.toString() + " others"),
      count > 0
          ? RoundedButton(
              text: "submit attestations",
              onPressed: () =>
                  _submit(context) // for testing always allow sending
              )
          : Container()
    ]);
  }

  Future<void> _submit(BuildContext context) async {
    print("All attestations full: " + store.encointer.attestations.toString());
    /*var attestations = store.encointer.attestations
      .map((key, value) => MapEntry(key, value.yourAttestation))
        .values
        .where((x) => x != null)
        .toList();
*/
    const claimTest =
        '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd57201000003000000';
    Map res =
        await webApi.encointer.attestClaimOfAttendance(claimTest, "123qwe");
    List<Attestation> attestations = new List();
    attestations.add(Attestation.fromJson(res['attestation']));
    attestations.add(Attestation.fromJson(res['attestation']));
    //attestations = [
    //  "0xbe9db4ecc6821c60f81a38c50526c971a94901368555b64e091da9bca8e7cc7ffb0f0000cef98d744e978f3e33724cfb5677d2104e020909fbec6e97c2c594aa607d78cb010000000000000000000000000000000000000000000000a07a2113730100000a000000a22d93c78073c7a1923a4dad3a1a186c0aa8135a86e6ff40612029bfade5423ced9a032c18c0023501ed0bde364d6fd25ce0853d3ae0d191a17b9f0304089b8abe9db4ecc6821c60f81a38c50526c971a94901368555b64e091da9bca8e7cc7f",
    //  "0xbe9db4ecc6821c60f81a38c50526c971a94901368555b64e091da9bca8e7cc7ffb0f0000cef98d744e978f3e33724cfb5677d2104e020909fbec6e97c2c594aa607d78cb010000000000000000000000000000000000000000000000a07a2113730100000a000000a22d93c78073c7a1923a4dad3a1a186c0aa8135a86e6ff40612029bfade5423ced9a032c18c0023501ed0bde364d6fd25ce0853d3ae0d191a17b9f0304089b8abe9db4ecc6821c60f81a38c50526c971a94901368555b64e091da9bca8e7cc7f"
    //];
    print("All attestations flat: " + jsonEncode(attestations));
    //return;
    var args = {
      "title": 'register_attestations',
      "txInfo": {
        "module": 'encointerCeremonies',
        "call": 'registerAttestations',
      },
      "detail": jsonEncode({
        "attestations": attestations,
      }),
      "params": [
        null, // TODO: attestations,
      ],
      'onFinish': (BuildContext txPageContext, Map res) {
        Navigator.popUntil(txPageContext, ModalRoute.withName('/'));
      }
    };
    Navigator.of(context).pushNamed(TxConfirmPage.route, arguments: args);
  }
}
