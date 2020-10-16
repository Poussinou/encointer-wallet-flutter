import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:polka_wallet/service/substrateApi/encointer/apiEncointer.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/encointer/types/attestation.dart';
import 'package:polka_wallet/store/encointer/types/claimOfAttendance.dart';

import 'data/mockEncointerData.dart';

class MockApiEncointer extends Mock implements ApiEncointer {}

// Todo: this might need to be refined and exteded
MockApiEncointer getMockApiEncointer() {
  final apiEncointer = MockApiEncointer();
  final store = globalAppStore;
  when(apiEncointer.getCurrentPhase()).thenAnswer((_) {
    return Future.value(store.encointer.currentPhase);
  });
  when(apiEncointer.getCurrentCeremonyIndex()).thenAnswer((invocation) {
    return Future.value(1);
  });
  when(apiEncointer.getNextMeetupTime()).thenAnswer((invocation) {
    return Future.value(null);
  });
  when(apiEncointer.getMeetupIndex()).thenAnswer((invocation) {
    return Future.value(1);
  });
  when(apiEncointer.getNextMeetupLocation()).thenAnswer((_) {
    return Future.value();
  });
  when(apiEncointer.getParticipantIndex()).thenAnswer((invocation) {
    return Future.value(1);
  });
  when(apiEncointer.getParticipantCount()).thenAnswer((invocation) {
    return Future.value(3);
  });
  when(apiEncointer.getParticipantCount()).thenAnswer((invocation) {
    return Future.value(3);
  });
  when(apiEncointer.getCurrencyIdentifiers()).thenAnswer((invocation) {
    return Future.value(currencyIdentifiers);
  });
  when(apiEncointer.getClaimOfAttendance(any)).thenAnswer((invocation) {
    return Future.value(claimHex);
  });
  when(apiEncointer.parseAttestation(any)).thenAnswer((invocation) {
    return Future.value(Attestation.fromJson(attestation));
  });
  when(apiEncointer.parseClaimOfAttendance(any)).thenAnswer((invocation) {
    return Future.value(ClaimOfAttendance.fromJson(claim));
  });
  when(apiEncointer.attestClaimOfAttendance(any, any)).thenAnswer((invocation) {
    return Future.value(AttestationResult.fromJson(attestationMap));
  });
  return apiEncointer;
}
