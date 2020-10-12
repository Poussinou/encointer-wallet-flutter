import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/roundedButton.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/page-encointer/meetup/attestation/components/stateMachinePartyA.dart';
import 'package:polka_wallet/page-encointer/meetup/attestation/components/stateMachinePartyB.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AttestationCard extends StatefulWidget {
  AttestationCard(
    this.store, {
    this.myMeetupRegistryIndex,
    this.otherMeetupRegistryIndex,
    this.claim,
  });

  static const String route = '/encointer/meetup/';
  final AppStore store;

  final int myMeetupRegistryIndex;
  final int otherMeetupRegistryIndex;
  final String claim;

  @override
  _AttestationCardState createState() => _AttestationCardState(store);
}

class _AttestationCardState extends State<AttestationCard> {
  _AttestationCardState(this.store);

  final AppStore store;

  @override
  void initState() {
    super.initState();
  }

  _performAttestation() async {
    print("performing attestation");
    if (widget.myMeetupRegistryIndex < widget.otherMeetupRegistryIndex) {
      await Navigator.of(context).pushNamed(StateMachinePartyA.route);
    } else {
      await Navigator.of(context).pushNamed(StateMachinePartyB.route);
    }
  }

  _revertAttestation() {
    print("reverting attestation");
  }

  @override
  Widget build(BuildContext context) {
    final Map dic = I18n.of(context).encointer;

    int otherIndex = widget.otherMeetupRegistryIndex;

    var attestation = store.encointer.attestations[otherIndex];
    print("Attestationcard for " + attestation.pubKey);
    return RoundedCard(
      border: Border.all(color: Theme.of(context).cardColor),
      margin: EdgeInsets.only(bottom: 16),
      child: Observer(
        builder: (_) => Container(
          decoration: store.encointer.attestations[widget.otherMeetupRegistryIndex].done
              ? BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(10)))
              : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(8.0),
                  //color: Colors.lime,
                  decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      border: Border.all(
                        color: Colors.yellow,
                        width: 4,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Text(
                    otherIndex.toString(),
                    style: TextStyle(fontSize: 24),
                  ) //AddressIcon(attestation.pubKey, size: 64),
                  ),
              Container(
                child: Text(
                  Fmt.address(attestation.pubKey),
                  style: TextStyle(fontSize: 16),
                ),
                //onTap: () => _scanQrCode(otherIndex),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                child: RoundedButton(
                    text: dic['attestation.perform'],
                    onPressed: store.encointer.attestations[widget.otherMeetupRegistryIndex].done
                        ? null
                        : () => _performAttestation()),
              )
            ],
          ),
        ),
      ),
    );
  }
}
