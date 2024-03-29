import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'signup.dart';
import 'package:http/http.dart' as http;
import 'mypage.dart';
import 'community.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

//SignIn 하는 부분.
//loginemail과 loginpw를 입력받고 user데이터에 있는지 확인해야할듯?
//이거 백엔드도 구현 안돼있을텐데..
class _SignInState extends State<SignIn> {
  var loginemail = TextEditingController();
  var loginpw = TextEditingController();
  var nickname = TextEditingController();
  var userlevel = TextEditingController();
  bool membercheck = false;
  bool communityCheck = true;

  getCommunityCheck() async {
    var url = Uri.parse('////');
    var result = await http.get(url);
    var result2 = jsonDecode(result.body);
    setState(() {
      if (result2 == false) {
        communityCheck = false;
      }
      ;
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<UserStore>().getData_users();
    //context.read<UserStore>().getData_communities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              //nickname
              child: TextField(
                controller: nickname,
                decoration: InputDecoration(
                    labelText: 'Nickname',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              //이메일
              child: TextField(
                controller: loginemail,
                decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
            //비밀번호
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: TextField(
                controller: loginpw,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              //멤버 레벨
              child: TextField(
                controller: userlevel,
                decoration: InputDecoration(
                    labelText: 'MEMBER or MANAGER',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
            //로그인 버튼, 회원가입으로 이동 텍스트, sizedbox는 그냥 정렬을 위한 것
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    child: Text('Sign In'),
                    onPressed: () {
                      //getCommunityCheck();
                      membercheck = context.read<UserStore>().isMember(
                          loginemail.text,
                          loginpw.text,
                          nickname.text,
                          userlevel.text);
                      if (membercheck) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (c) => MyApp()));
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Sign in Error',
                                style: TextStyle(color: Colors.red),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('ok'))
                              ],
                            );
                          },
                        );
                      }
                    }),
                GestureDetector(
                  child: Text('Sign up'),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (c) => SignUp()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//state 보관함
class UserStore extends ChangeNotifier {
  var communities = [];
  List<dynamic> users = [
    {
      "userid": 1,
      "nickname": "12345",
      "email": "12345",
      "password": "12345",
      "userLevel": "MEMBER",
      "community": null
    },
  ];
  var mypageid;
  var mygrade;

  Future<void> getData_users() async {
    var url = Uri.parse('https://server-irxa6nl5aa-uc.a.run.app/auth/alluser');
    final response = await http.get(url);

    var result2 = json.decode(response.body);
    users = result2;
    //print(users);

    notifyListeners();
  }

  getData_communities() async {
    var result = await http.get(Uri.parse(''));
    var result2 = jsonDecode(result.body);
    communities = result2;
    notifyListeners();
  }

  isMember(id, pw, nickname, level) {
    bool check = false;

    for (var user in users) {
      if (user["email"] == id &&
          user["password"] == pw &&
          user["nickname"] == nickname &&
          user["userLevel"] == level) {
        check = true;
        break; // 모든 필드가 일치하는 사용자를 찾았으므로 더 이상 검색할 필요 없음
      }
    }

    notifyListeners();
    return check;
  }

  //회원가입 시 닉네임, 이메일, 비밀번호 저장하는 함수
  addUser(name, email, pw, level) {
    var userData = {
      'userid': users.length,
      'nickname': name,
      'email': email,
      'password': pw,
      'userLevel': level,
    };
    users.add(userData);
    notifyListeners();
  }

  //커뮤니티 추가
  addCommunity(name, date) {
    //커뮤니티 이름과 게시물 지속 날짜 저장
    var commutityData = {
      'communityName': name,
      'postsExposurePeriod': date,
    };
    communities.add(commutityData);

    notifyListeners();
  }

  //커뮤니티 검색
  searchData(a) {
    //커뮤니티 검색에 들어간 단어들 데이터베이스로 보내는 함수
    var result = false;
    for (var com in communities) {
      if (com['communityName'] == a) {
        result = com['communityName'];
        users[mypageid]['community'] = com['communityName'];
      }
    }
    notifyListeners();
    return result;
  }
}
