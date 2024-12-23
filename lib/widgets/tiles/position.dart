import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

final class YourPositionTile extends StatelessWidget {
  const YourPositionTile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: theme.colorScheme.primary,
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(220),
            ),
            padding:
                const EdgeInsets.only(top: 3, right: 5, left: 5, bottom: 3),
            child: Icon(
              MingCuteIcons.mgc_map_pin_line,
              size: 28,
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}

final class YourPositionExpanded extends StatelessWidget {
  final Function() onTap;

  const YourPositionExpanded({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return ListTile(
      leading: YourPositionTile(),
      title: Text(
        loc.yourPosition,
        overflow: TextOverflow.clip,
      ),
      horizontalTitleGap: 5,
      isThreeLine: false,
      onTap: () => onTap(),
    );
  }
}
