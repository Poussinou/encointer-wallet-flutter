const Map<String, dynamic> claim = {
  'claimant_public': '5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY',
  'ceremony_index': 63,
  'currency_identifier': '0x22c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d3',
  'meetup_index': 1,
  'location': {'lon': '79643934720', 'lat': '152403291178'},
  'timestamp': 1592719549549,
  'number_of_participants_confirmed': 3
};

String claimHex =
    '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d30100000000000000968680d300000000a8184851040000006da47bd57201000003000000';

const Map<String, dynamic> attestationMap = {
  'attestation': attestation,
  'attestationHex': attestationHex,
};

const Map<String, dynamic> attestation = {
  'claim': claim,
  'signature':
      '0x01a011d3be75a2448a72876967b859cba02226f41b1a9c179aac4733f5cb74c1096721c89eb4604100813dd99001fb888ded2fd1957dd4ee6891a6f2d30e9da98e',
  'public': '5DPgv6nn4R1Gi1MUiAnzFDPaKF56SYKD9Zq4Q6REUGLhUZk1'
};

const String attestationHex =
    '0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d3f00000022c51e6a656b19dd1e34c6126a75b8af02b38eedbeec51865063f142c83d40d301000000000000002aacf17b230000000000268b120000006da47bd5720100000300000001864e24338bf1be2f9a304a67ca1b166f72e76919202109c4ef5b8b6f0e5c00238b7ecc8cc30de924443971dd001a79010ff34c16ca42413eb831e549775a858d8eaf04151687736326c9fea17e25fc5287613693c912909cb226aa4794f26a48';

const List<dynamic> currencyIdentifiers = [
  '0xf26bfaa0feee0968ec0637e1933e64cd1947294d3b667d43b76b3915fc330b53',
  '0x2ebf164a5bb618ec6caad31488161b237e24d75efa3040286767b620d9183989',
  '0xc792bf36f892404a27603ffd14cd5a12e794ed3c740bab0929ba55b8c747c615',
];
