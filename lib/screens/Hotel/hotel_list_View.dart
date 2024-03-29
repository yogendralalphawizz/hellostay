import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hellostay/constants/colors.dart';
import 'package:hellostay/model/hotel_search_response.dart';
import 'package:hellostay/repository/apiConstants.dart';
import 'package:hellostay/utils/date_function.dart';
import 'package:hellostay/utils/draggable_sheet.dart';
import 'package:hellostay/utils/traver_tile.dart';
import 'package:hellostay/widgets/custom_app_button.dart';
import 'package:hellostay/widgets/select_date_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../repository/apiStrings.dart';
import 'homeView.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen(
      {Key? key,
      this.title,
      this.userId,
      this.checkIn,
      this.checkOut,
      this.adults,
      this.lat,
      this.long,
      this.address,
      this.children})
      : super(key: key);
  final String? title, userId;
  final String? checkIn, checkOut, address, lat, long;

  final int? adults, children;

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  var searchedHotel;

//  Api api = Api();

  var data;

  @override
  void initState() {
    // TODO: implement initState.
    inIt();

    super.initState();
  }

  inIt() async {
    await getSearchedHotel();
  }

  @override
  Widget build(BuildContext context) {
    var _appBar = PreferredSize(
      preferredSize: const Size.fromHeight(45.0),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title ?? '',
            style: const TextStyle(fontFamily: "Sofia", color: Colors.black)),
      ),
    );

    var _topAnaheim = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
          child: Text(
            'Top Choice',
            style: TextStyle(
                fontFamily: "Sofia",
                fontSize: 20.0,
                fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
            height: 320.0,
            child: card(
              list: hotelList,
              /*dataUser: widget.userId,
            list: snapshot.data.docs,*/
            )),
        const SizedBox(
          height: 25.0,
        ),
      ],
    );

    return Scaffold(
      appBar: _appBar,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                InkWell(
                    onTap: () async {
                      _showBottomSheetforDate(context);
                    },
                    child:  Text(
                      '${widget.checkIn}',
                      style: TextStyle(color: AppColors.secondary),
                    )),
                const SizedBox(
                  width: 15,
                ),
                Container(
                    padding: const EdgeInsets.all(5),
                    color: AppColors.faqanswerColor.withOpacity(0.2),
                    child: const Icon(
                      Icons.compare_arrows,
                      size: 14,
                    )),
                const SizedBox(
                  width: 15,
                ),
                 InkWell(
                   onTap: (){
                     _showBottomSheetforDate(context);
                   },
                   child: Text(
                    '${widget.checkOut}',
                    style: TextStyle(color: AppColors.secondary),
                ),
                 ),
                const SizedBox(
                  width: 15,
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: AppColors.faqanswerColor,
                ),
                const SizedBox(
                  width: 15,
                ),
                 Text(
                  '${room} rooms',
                  style: TextStyle(color: AppColors.secondary),
                ),
                const SizedBox(
                  width: 15,
                ),
                 Text(
                  '${childrenCount1+adultCount1} guest',
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 15,),
            Container(
                width: 80,
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.faqanswerColor.withOpacity(0.5))
                ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                const Text('Sort'),
                Icon(Icons.sort, color: AppColors.faqanswerColor.withOpacity(0.5),),
              ],),),
            ),
            const Divider(),

            _topAnaheim,
          ],
        ),
      ),
    );
  }

  List<HotelDataList> hotelList = [];

  getSearchedHotel() async {
    try {
      var params = {'start': '${widget.checkIn}', 'end': '${widget.checkOut}'};

      List<Map<String, String>> guestsList = [];

      for (int i = 0; i < adultCountList.length; i++) {
        Map<String, String> guestData = {
          'adults[$i]': adultCountList[i].toString(),
          'children[$i]': childrenCountList[i].toString(),
        };
        guestsList.add(guestData);
      }

      var data = addMapListToData(params, guestsList);

      apiBaseHelper.postAPICall(hotelSearch, data).then((getData) {
        hotelList = HotelSearchResponse.fromJson(getData).data ?? [];

        setState(() {});
      });
    } catch (e) {
      setState(() {
        print('__${e}___________');
        isLoading = false;
      });
    } finally {
      /*setState(() {
        isLoading = false;
      });*/
    }
  }

  var hotelDetailsResponse;
  var hotelSearchListData;
  List<dynamic> hotels = [];
  bool isLoading = false;

  Map<String, String> addMapListToData(
      Map<String, String> data, List<Map<String, dynamic>> mapList) {
    for (var map in mapList) {
      map.forEach((key, value) {
        data[key] = value;
      });
    }
    return data;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.001),
            child: GestureDetector(
              onTap: () {},
              child: const MyDraggableSheetState(),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheetforDate(BuildContext context) {
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(),
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            //height: 800,
            color: const Color.fromRGBO(0, 0, 0, 0.001),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 2,
                    color: AppColors.faqanswerColor,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () async {
                            String date = await selectDate(context);

                            checkInDate = date;

                            formattedCheckInDate = DateFormat("dd MMM''yy")
                                .format(DateTime.parse(date));
                            checkInDayOfWeek = DateFormat("EEEE")
                                .format(DateTime.parse(date));
                          },
                          child: selectDateWidget(
                              'Check-in',
                              checkInDayOfWeek,
                              formattedCheckInDate,
                              true,
                              context)),
                      const Icon(
                        Icons.nights_stay,
                        color: AppColors.faqanswerColor,
                      ),
                      InkWell(
                          onTap: () async {
                            String date = await selectDate(context);

                            checkInDate = date;

                            formattedCheckInDate = DateFormat("dd MMM''yy")
                                .format(DateTime.parse(date));
                            checkInDayOfWeek = DateFormat("EEEE")
                                .format(DateTime.parse(date));
                          },
                          child: selectDateWidget(
                              'Check-in',
                              checkInDayOfWeek,
                              formattedCheckInDate,
                              true,
                              context))
                    ],
                  ),
                  TravelDetailsTile(),


                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBottomSheetforSorting(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(),
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            //height: 800,
            color: const Color.fromRGBO(0, 0, 0, 0.001),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 2,
                    color: AppColors.faqanswerColor,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  const Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                  const SizedBox(height: 5,),



                ],
              ),
            ),
          ),
        );
      },
    );
  }


  getHotelList(String element) async {
    /*var headers = {
      'Content-Type': 'application/json',
      'apikey': apiKey
    };
    var request =
    http.Request('POST', Uri.parse('${flightUrl}hms/v1/hotel-search'));
    request.body = json.encode({"searchId": element});
    request.headers.addAll(headers);

    print('${request.body}');

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();

      final jsonResponse =
      HotelSearchListData.fromJson(json.decode(finalResult));

      hotelSearchListData = jsonResponse;
      // hotels.clear();

      hotels = hotelSearchListData?.searchResult?.his ?? [];

      setState(() {
        isLoading = false;
      });
    } else {
      print(response.reasonPhrase);
    }*/
  }
}


class Sort {
  String? titel;
  IconData? icon ;
  bool? isSelected;

  Sort({this.titel, this.icon, this.isSelected});
}



















class card extends StatelessWidget {
  final String? dataUser;
  final List<HotelDataList>? list;

  card({this.dataUser, this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        primary: false,
        itemCount: list?.length ?? 0,
        itemBuilder: (context, i) {
          //List<String> photo = List.from(list[i].data()['photo']);
          // List<String> service = List.from(list[i].data()['service']);
          // List<String> description = List.from(list[i].data()['description']);
          String title = 'title';
          // String type = list[i].data()['type'].toString();
          double rating = 4.5;
          String location = 'location';
          String image =
              'https://media-cdn.tripadvisor.com/media/photo-m/1280/21/dc/28/e0/fortune-pandiyan-hotel.jpg';
          String id = 'id2';
          num price = 1500;
          //num latLang1 = list[i].data()['latLang1'];
          // num latLang2 = list[i].data()['latLang2'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    /*Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => new TopChoiceDetail(
                          userId: dataUser,
                          titleD: title,
                          idD: id,
                          imageD: image,
                          latLang1D: latLang1,
                          latLang2D: latLang2,
                          locationD: location,
                          priceD: price,
                          descriptionD: description,
                          photoD: photo,
                          ratingD: rating,
                          serviceD: service,
                          typeD: type,
                        ),
                        transitionDuration: Duration(milliseconds: 600),
                        transitionsBuilder:
                            (_, Animation<double> animation, __, Widget child) {
                          return Opacity(
                            opacity: animation.value,
                            child: child,
                          );
                        }));*/
                  },
                  child: Hero(
                    tag: 'hero-tag-${id}',
                    child: Material(
                      child: Container(
                        height: 220.0,
                        width: 160.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(image), fit: BoxFit.cover),
                            color: Colors.black12,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 5.0,
                                  color: Colors.black12.withOpacity(0.1),
                                  spreadRadius: 2.0)
                            ]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  title,
                  style: const TextStyle(
                      fontFamily: "Sofia",
                      fontWeight: FontWeight.w600,
                      fontSize: 17.0,
                      color: Colors.black87),
                ),
                const SizedBox(
                  height: 2.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.location_on,
                      size: 18.0,
                      color: Colors.black12,
                    ),
                    Text(
                      location,
                      style: const TextStyle(
                          fontFamily: "Sofia",
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          color: Colors.black26),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.star,
                      size: 18.0,
                      color: Colors.yellow,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        rating.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: "Sofia",
                            fontSize: 13.0),
                      ),
                    ),
                    const SizedBox(
                      width: 35.0,
                    ),
                    Container(
                      height: 27.0,
                      width: 82.0,
                      decoration: const BoxDecoration(
                          color: Color(0xFF09314F),
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      child: Center(
                        child: Text("\$ " + price.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 13.0)),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }
}

class cardList extends StatelessWidget {
  final List<dynamic>? hotels;

  final _txtStyleTitle = const TextStyle(
    color: Colors.black87,
    fontFamily: "Gotik",
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
  );

  final _txtStyleSub = const TextStyle(
    color: Colors.black26,
    fontFamily: "Gotik",
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
  );

  cardList({
    this.hotels,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        itemCount: hotels?.length ?? 0,
        itemBuilder: (context, i) {
          // List<String> photo = List.from(list[i].data()['photo']);
          //List<String> service = List.from(list[i].data()['service']);
          //List<String> description = List.from(list[i].data()['description']);
          String title = hotels?[i].name ?? '';
          // String type = list[i].data()['type'].toString();
          num rating = hotels?[i].rt ?? 4.5;
          String location = hotels?[i].ad?.city?.name ?? '';
          String image2 =
              'https://www.seleqtionshotels.com/content/dam/seleqtions/Connaugth/TCPD_PremiumBedroom4_1235.jpg/jcr:content/renditions/cq5dam.web.1280.1280.jpeg';
          String image = hotels?[i].img?.first.url ?? image2;
          String id = hotels?[i].id ?? '';
          num price = hotels?[i].pops?.first.tpc ?? 2000;
          String latLang1 = hotels?[i].gl?.ln ?? '';
          String latLang2 = hotels?[i].gl?.lt ?? '';

          return Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
            child: InkWell(
              onTap: () {
                /*Navigator.of(context).push( PageRouteBuilder(
                    pageBuilder: (_, __, ___) => HotelDetail2(
                          titleD: title,
                          idD: id,
                          imageD: image,
                          latLang1D: latLang1,
                          latLang2D: latLang2,
                          locationD: location,
                          priceD: price,
                          ratingD: rating,
                        ),
                    transitionDuration: const Duration(milliseconds: 600),
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return Opacity(
                        opacity: animation.value,
                        child: child,
                      );
                    }));*/
              },
              child: Container(
                height: 250.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12.withOpacity(0.1),
                          blurRadius: 3.0,
                          spreadRadius: 1.0)
                    ]),
                child: Column(children: [
                  Hero(
                    tag: 'hero-tag-${id}',
                    child: Material(
                      child: Container(
                        height: 165.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10.0),
                              topLeft: Radius.circular(10.0)),
                          image: DecorationImage(
                              image: NetworkImage(image), fit: BoxFit.cover),
                        ),
                        alignment: Alignment.topRight,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width: 210.0,
                                  child: Text(
                                    title,
                                    style: _txtStyleTitle,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              const Padding(padding: EdgeInsets.only(top: 5.0)),
                              Row(
                                children: <Widget>[
                                  /*ratingbar(
                                    starRating: rating.toDouble(),
                                    color: const Color(0xFF09314F),
                                  ),*/
                                  const Padding(
                                      padding: EdgeInsets.only(left: 5.0)),
                                  Text(
                                    "(" + rating.toString() + ")",
                                    style: _txtStyleSub,
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.location_on,
                                      size: 16.0,
                                      color: Colors.black26,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.only(top: 3.0)),
                                    Text(location, style: _txtStyleSub)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FittedBox(
                                clipBehavior: Clip.antiAlias,
                                child: Text(
                                  "\$" + price.toStringAsFixed(0),
                                  style: const TextStyle(
                                      fontSize: 22.0,
                                      color: Color(0xFF09314F),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Gotik"),
                                ),
                              ),
                              Text("per night",
                                  style: _txtStyleSub.copyWith(fontSize: 11.0))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
            ),
          );
        });
  }
}
