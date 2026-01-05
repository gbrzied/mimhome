import 'package:http/http.dart' as http;
import 'package:millime/core/build_info.dart';

  
const int BACKEND_PORT = 8081;
  Future<dynamic> fetchPersonnePbyPieceIdentite(
      String codePiece, String numPiece) async {
  //  isOtpLoading = true;

    if (numPiece.isEmpty) return null;
    final response = await http
        .get(Uri.parse('http://${backendServer}:8081/pp/' + numPiece + '/pp'));

    dynamic pp;
    if (response.statusCode == 200 && response.contentLength! > 0) {
     // pp = PersonneP.fromJson(jsonDecode(response.body));
      pp=response.body;
      //print(pp.ppId);
    } else {
      // return Future.error(response.body);
      return null;
    }

    return pp;
  }


  bool isValidRNE(String code) {
    bool rneValide = false;

    var non = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'];
    int i, s = 0;
    String d;

    if (code.length == 8) {
      for (i = 1; i < 8; i++) {
        d = code[i - 1];

        try {
          s = s + int.parse(d) * (8 - i);
        } catch (exception) {
          print('Parse error $exception');
          return false;
        }
      }
      if (s > 0) {
        rneValide = (non[s % 23] == code[7]);
      }

      return rneValide;
    } else {
      return false;
    }
  }
    Future<dynamic> fetchDocInYByNoPieceIdentite(String numPiece,
      String codePiece, String typePersonne, String codeDocinX) async {
    final response = await http.get(Uri.parse(
        'http://${backendServer}:8081/docInY/byNoPieceIdentite/' +
            numPiece +
            '/' +
            codePiece +
            '/' +
            typePersonne +
            '/' +
            codeDocinX));

    // dynamic dociny;

    if (response.statusCode == 200 && response.contentLength! > 0) {
    //   dociny = DocInY.fromJson(jsonDecode(response.body));
    // } else {
    //   dociny = null;
    // }
        return response.body;

    }
    return null;
  }


bool isValidTunisianMobile(String phone) {
  // Regex Breakdown:
  // ^       : Start of string
  // [2459]  : First digit must be 2, 4, 5, or 9
  // [0-9]{7}: Followed by exactly 7 more digits
  // $       : End of string
  final RegExp mobileRegex = RegExp(r'^[2459][0-9]{7}$');

  return mobileRegex.hasMatch(phone);
}