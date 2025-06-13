import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'variables.dart';
import 'package:provider/provider.dart';
import '../Providers/darkmode_page.dart';
import 'ms_massage_search_in_chat.dart';
import 'ms_massage_searching.dart';

class MessageTabScreen extends StatefulWidget {
  const MessageTabScreen({super.key});

  @override
  State<MessageTabScreen> createState() => _MessageTabScreen();
}

class _MessageTabScreen extends State<MessageTabScreen> {
  late ColorProvider notifier;

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifier.getBgColor,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 15),
                child: Text(
                  "Inbox",
                  style: GoogleFonts.plusJakartaSans(
                    color: notifier.mainTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.push(
                        context,
                        CupertinoDialogRoute(
                          builder: (context) {
                            return const MassageSearch();
                          },
                          context: context,
                        ),
                      );
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: notifier.textFieldColor,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    width: double.maxFinite,
                    height: 60,
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 15.0, right: 10),
                            child: SvgPicture.asset(
                              "Assets/SVG/seachIcon.svg",
                              colorFilter: ColorFilter.mode(
                                  notifier.descriptionTextColor,
                                  BlendMode.srcIn),
                            ),
                          ),
                          Text(
                            "Search for a friend or partners",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: notifier.descriptionTextColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.push(
                              context,
                              CupertinoDialogRoute(
                                builder: (context) {
                                  return MassageScreenChat(
                                    whatsappDate: whatsappDates[index],
                                    storyImage: storyImages[index],
                                    personName: personNameChat[index],
                                  );
                                },
                                context: context,
                              ),
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: notifier.borderColor,
                                width: 1,
                              ),
                            ),
                          ),
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                leading: Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff8f8f8),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Image.asset(
                                        storyImages[index],
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      )),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    personNameChat[index],
                                    style: GoogleFonts.plusJakartaSans(
                                      color: notifier.mainTextColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                subtitle: Text(
                                  messages[index],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: notifier.descriptionTextColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Text(
                                  whatsappDates[index],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: notifier.descriptionTextColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: storyImages.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
