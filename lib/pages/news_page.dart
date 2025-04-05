import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/utils.dart';
import 'package:trasportimus_repository/model/model.dart' as m;
import 'package:url_launcher/link.dart';

class NewsPage extends StatelessWidget {
  final List<m.News> news;
  final m.Route route;

  const NewsPage(this.route, this.news, {super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            loc.news(route.shortName),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(MingCuteIcons.mgc_arrow_left_line),
          ),
          flexibleSpace: Container(
            decoration: Defaults.decoration,
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: news.length,
            itemBuilder: (context, index) {
              var theme = Theme.of(context);
              m.News data = news[index];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.header,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      data.details,
                      softWrap: true,
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Link(
                    uri: data.url,
                    builder: (context, followLink) {
                      return ElevatedButton(
                        onPressed: followLink,
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                theme.colorScheme.primary),
                            foregroundColor: WidgetStatePropertyAll(
                                theme.colorScheme.onPrimary)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                loc.goToNews,
                              ),
                            ),
                            Icon(
                              MingCuteIcons.mgc_share_3_line,
                              color: theme.colorScheme.onPrimary,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: theme.colorScheme.primary,
                  )
                ],
              );
            },
          ),
        ));
  }
}
