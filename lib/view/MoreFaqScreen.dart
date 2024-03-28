import 'package:flutter/material.dart';
import 'package:mobile/util/constant.dart';
import 'package:mobile/view/CustomTextWidget.dart';

class MoreFaqScreen extends StatefulWidget {
  @override
  _MoreFaqScreenState createState() => _MoreFaqScreenState();
}

class _MoreFaqScreenState extends State<MoreFaqScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Constant.backgroundBoxDecoration,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: RawScrollbar(
              thickness: 2,
              thumbColor: Constant.locationServiceGreen,
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Constant.moreBackgroundColor,
                        ),
                        child: Row(
                          children: [
                            Image(
                              width: 20,
                              height: 20,
                              image: AssetImage(Constant.leftArrow),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            CustomTextWidget(
                              text: Constant.support,
                              style: TextStyle(
                                  color: Constant.locationServiceGreen,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Constant.moreBackgroundColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextWidget(
                                text: Constant.faqQuestion1,
                                style: TextStyle(
                                  color: Constant.addCustomNotificationTextColor,
                                  fontSize: 16,
                                  fontFamily: Constant.jostMedium
                                ),
                              ),
                              SizedBox(height: 5,),
                              CustomTextWidget(
                                text: Constant.faqAnswer1,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: Constant.locationServiceGreen,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextWidget(
                                text: Constant.faqQuestion2,
                                style: TextStyle(
                                    color: Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              SizedBox(height: 5,),
                              CustomTextWidget(
                                text: Constant.faqAnswer2,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: Constant.locationServiceGreen,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextWidget(
                                text: Constant.faqQuestion3,
                                style: TextStyle(
                                    color: Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              SizedBox(height: 5,),
                              CustomTextWidget(
                                text: Constant.faqAnswer3,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: Constant.locationServiceGreen,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextWidget(
                                text: Constant.faqQuestion4,
                                style: TextStyle(
                                    color: Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              SizedBox(height: 5,),
                              CustomTextWidget(
                                text: Constant.faqAnswer4,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              Divider(
                                height: 30,
                                thickness: 0.5,
                                color: Constant.locationServiceGreen,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextWidget(
                                text: Constant.faqQuestion5,
                                style: TextStyle(
                                    color: Constant.addCustomNotificationTextColor,
                                    fontSize: 16,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                              SizedBox(height: 5,),
                              CustomTextWidget(
                                text: Constant.faqAnswer5,
                                style: TextStyle(
                                    color: Constant.locationServiceGreen,
                                    fontSize: 14,
                                    fontFamily: Constant.jostMedium
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height:20,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
