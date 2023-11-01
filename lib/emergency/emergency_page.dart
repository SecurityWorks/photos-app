import 'package:flutter/material.dart';
import 'package:photos/core/configuration.dart';
import "package:photos/emergency/emergency_service.dart";
import "package:photos/emergency/model.dart";
import "package:photos/emergency/other_contact_page.dart";
import "package:photos/emergency/select_contact_page.dart";
import "package:photos/generated/l10n.dart";
import "package:photos/models/api/collection/user.dart";
import 'package:photos/theme/ente_theme.dart';
import "package:photos/ui/common/loading_widget.dart";
import "package:photos/ui/components/action_sheet_widget.dart";
import "package:photos/ui/components/buttons/button_widget.dart";
import 'package:photos/ui/components/captioned_text_widget.dart';
import 'package:photos/ui/components/divider_widget.dart';
import 'package:photos/ui/components/menu_item_widget/menu_item_widget.dart';
import 'package:photos/ui/components/menu_section_title.dart';
import "package:photos/ui/components/models/button_type.dart";
import "package:photos/ui/components/notification_widget.dart";
import 'package:photos/ui/components/title_bar_title_widget.dart';
import 'package:photos/ui/components/title_bar_widget.dart';
import "package:photos/ui/sharing/user_avator_widget.dart";
import "package:photos/utils/navigation_util.dart";
import "package:photos/utils/toast_util.dart";

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({
    super.key,
  });

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late int currentUserID;
  EmergencyInfo? info;

  @override
  void initState() {
    super.initState();
    currentUserID = Configuration.instance.getUserID()!;
    // set info to null after 5 second
    Future.delayed(
      const Duration(seconds: 0),
      () async {
        try {
          final result = await EmergencyContactService.instance.getInfo();
          if (mounted) {
            setState(() {
              info = result;
            });
          }
        } catch (e) {
          showShortToast(
            context,
            S.of(context).somethingWentWrong,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = getEnteColorScheme(context);
    final currentUserID = Configuration.instance.getUserID()!;
    final User owner = User(
      id: 1,
      email: "",
    );
    if (owner.id == currentUserID && owner.email == "") {
      owner.email = Configuration.instance.getEmail()!;
    }

    final List<EmergencyContact> othersTrustedContacts =
        info?.othersEmergencyContact ?? [];
    final List<EmergencyContact> trustedContacts = info?.contacts ?? [];

    return Scaffold(
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          const TitleBarWidget(
            flexibleSpaceTitle: TitleBarTitleWidget(
              title: "Trusted Contacts",
            ),
          ),
          if (info == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EnteLoadingWidget(),
              ),
            ),
          if (info != null)
            if (info!.recoverSessions.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NotificationWidget(
                            startIcon: Icons.warning_amber_rounded,
                            text: "Your trusted contact is trying to "
                                "access your account",
                            actionIcon: null,
                            onTap: () {},
                          ),
                        );
                      }
                      final RecoverySessions recoverSession =
                          info!.recoverSessions[index - 1];
                      return MenuItemWidget(
                        captionedTextWidget: CaptionedTextWidget(
                          title: recoverSession.emergencyContact.email,
                          makeTextBold: recoverSession.status.isNotEmpty,
                          textColor: colorScheme.warning500,
                        ),
                        leadingIconWidget: UserAvatarWidget(
                          recoverSession.emergencyContact,
                          currentUserID: currentUserID,
                        ),
                        leadingIconSize: 24,
                        menuItemColor: colorScheme.fillFaint,
                        singleBorderRadius: 8,
                        isGestureDetectorDisabled: true,
                      );
                    },
                    childCount: 1 + info!.recoverSessions.length,
                  ),
                ),
              ),
          if (info != null)
            SliverPadding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0 && trustedContacts.isNotEmpty) {
                      return const MenuSectionTitle(
                        title: "Your Trusted Contact",
                        iconData: Icons.emergency_outlined,
                      );
                    } else if (index > 0 && index <= trustedContacts.length) {
                      final listIndex = index - 1;
                      final currentUser = trustedContacts[listIndex];
                      final isLastItem = index == trustedContacts.length;
                      return Column(
                        children: [
                          MenuItemWidget(
                            captionedTextWidget: CaptionedTextWidget(
                              title: currentUser.emergencyContact.email,
                              subTitle: currentUser.isPendingInvite()
                                  ? currentUser.state.stringValue
                                  : null,
                              makeTextBold: currentUser.isPendingInvite(),
                            ),
                            leadingIconSize: 24.0,
                            leadingIconWidget: UserAvatarWidget(
                              currentUser.emergencyContact,
                              type: AvatarType.mini,
                              currentUserID: currentUserID,
                            ),
                            menuItemColor:
                                getEnteColorScheme(context).fillFaint,
                            trailingIcon: Icons.chevron_right,
                            trailingIconIsMuted: true,
                            onTap: null,
                            isTopBorderRadiusRemoved: listIndex > 0,
                            isBottomBorderRadiusRemoved: !isLastItem,
                            singleBorderRadius: 8,
                          ),
                          isLastItem
                              ? const SizedBox.shrink()
                              : DividerWidget(
                                  dividerType: DividerType.menu,
                                  bgColor:
                                      getEnteColorScheme(context).fillFaint,
                                ),
                        ],
                      );
                    } else if (index == (1 + trustedContacts.length)) {
                      return MenuItemWidget(
                        captionedTextWidget: CaptionedTextWidget(
                          title: trustedContacts.isNotEmpty
                              ? S.of(context).addMore
                              : "Add Trusted Contact",
                          makeTextBold: true,
                        ),
                        leadingIcon: Icons.add_outlined,
                        menuItemColor: getEnteColorScheme(context).fillFaint,
                        onTap: () async {
                          routeToPage(
                            context,
                            AddContactPage(info!),
                          );
                          // _navigateToAddUser(false);
                        },
                        isTopBorderRadiusRemoved: trustedContacts.isNotEmpty,
                        singleBorderRadius: 8,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  childCount: 1 + trustedContacts.length + 1,
                ),
              ),
            ),
          if (info != null && info!.othersEmergencyContact.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0 && (othersTrustedContacts.isNotEmpty)) {
                      return const MenuSectionTitle(
                        title: "You're Their Trusted Contact",
                        iconData: Icons.photo_outlined,
                      );
                    } else if (index > 0 &&
                        index <= othersTrustedContacts.length) {
                      final listIndex = index - 1;
                      final currentUser = othersTrustedContacts[listIndex];
                      final isLastItem = index == othersTrustedContacts.length;
                      return Column(
                        children: [
                          MenuItemWidget(
                            captionedTextWidget: CaptionedTextWidget(
                              title: currentUser.user.email,
                              makeTextBold: currentUser.isPendingInvite(),
                              subTitle: currentUser.isPendingInvite()
                                  ? currentUser.state.stringValue
                                  : null,
                            ),
                            leadingIconSize: 24.0,
                            leadingIconWidget: UserAvatarWidget(
                              currentUser.user,
                              type: AvatarType.mini,
                              currentUserID: currentUserID,
                            ),
                            menuItemColor:
                                getEnteColorScheme(context).fillFaint,
                            trailingIcon: Icons.chevron_right,
                            trailingIconIsMuted: true,
                            onTap: () async {
                              if (currentUser.isPendingInvite()) {
                                await showAcceptOrDeclineDialog(
                                  context,
                                  currentUser,
                                );
                              } else {
                                routeToPage(
                                  context,
                                  OtherContactPage(contact: currentUser),
                                );
                              }
                            },
                            isTopBorderRadiusRemoved: listIndex > 0,
                            isBottomBorderRadiusRemoved: !isLastItem,
                            singleBorderRadius: 8,
                          ),
                          isLastItem
                              ? const SizedBox.shrink()
                              : DividerWidget(
                                  dividerType: DividerType.menu,
                                  bgColor:
                                      getEnteColorScheme(context).fillFaint,
                                ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  childCount: 1 + othersTrustedContacts.length + 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> showAcceptOrDeclineDialog(
    BuildContext context,
    EmergencyContact contact,
  ) async {
    await showActionSheet(
      context: context,
      buttons: [
        ButtonWidget(
          labelText: S.of(context).acceptTrustInvite,
          buttonType: ButtonType.primary,
          buttonSize: ButtonSize.large,
          shouldStickToDarkTheme: true,
          buttonAction: ButtonAction.first,
          onTap: () async {
            await EmergencyContactService.instance
                .updateContact(contact, ContactState.ContactAccepted);
            final updatedContact =
                contact.copyWith(state: ContactState.ContactAccepted);
            info?.othersEmergencyContact.remove(contact);
            info?.othersEmergencyContact.add(updatedContact);
            if (mounted) {
              setState(() {});
            }
          },
          isInAlert: true,
        ),
        ButtonWidget(
          labelText: S.of(context).declineTrustInvite,
          buttonType: ButtonType.critical,
          buttonSize: ButtonSize.large,
          buttonAction: ButtonAction.second,
          shouldStickToDarkTheme: true,
          onTap: () async {
            await EmergencyContactService.instance
                .updateContact(contact, ContactState.ContactDenied);
            info?.othersEmergencyContact.remove(contact);
            if (mounted) {
              setState(() {});
            }
          },
          isInAlert: true,
        ),
        ButtonWidget(
          labelText: S.of(context).cancel,
          buttonType: ButtonType.tertiary,
          buttonSize: ButtonSize.large,
          buttonAction: ButtonAction.third,
          shouldStickToDarkTheme: true,
          isInAlert: true,
        ),
      ],
      body:
          "You have been invited to be a trusted contact by ${contact.user.email}",
      actionSheetType: ActionSheetType.defaultActionSheet,
    );
    return;
  }
}
