import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:trasportimus/blocs/transport/transport_bloc.dart';
import 'package:trasportimus_repository/model/model.dart' as m;

int compareRoutes(m.Route r1, m.Route r2) {
  String n1 = r1.shortName;
  String n2 = r2.shortName;

  if (n1.endsWith('/')) {
    n1 = n1.substring(0, n1.length - 1);
  }
  if (n2.endsWith('/')) {
    n2 = n2.substring(0, n2.length - 1);
  }

  int? v1 = int.tryParse(n1);
  int? v2 = int.tryParse(n2);
  if (v1 != null && v2 != null) {
    return v1.compareTo(v2);
  } else if (v1 != null) {
    return -1;
  } else if (v2 != null) {
    return 1;
  } else {
    return n1.compareTo(n2);
  }
}

int compareStops(m.Stop s1, m.Stop s2) {
  String n1 = s1.name;
  String n2 = s2.name;

  return n1.compareTo(n2);
}

List<m.Trip> sortTrips(List<m.Trip> trips, m.Stop refStop, DateTime refTime) {
  var iter =
      trips.map((trip) => (getStopSt(trip, refStop, refTime), trip)).toList();
  iter.sort(
    (a, b) {
      var arrivalTimeCmp = a.$1.arrivalTime.compareTo(b.$1.arrivalTime);
      if (arrivalTimeCmp != 0) {
        return arrivalTimeCmp;
      }
      return compareRoutes(a.$2.route, b.$2.route);
    },
  );
  return iter.map((el) => el.$2).toList();
}

int compareTripsAtStop(m.Trip t1, m.Trip t2, m.Stop stop) {
  m.StopTime st1 = t1.stopTimes.firstWhere((st) => st.stop.id == stop.id);
  m.StopTime st2 = t2.stopTimes.firstWhere((st) => st.stop.id == stop.id);

  return st1.arrivalTime.compareTo(st2.arrivalTime);
}

m.StopTime getStopSt(m.Trip trip, m.Stop stop, DateTime refTime) {
  m.StopTime? res;
  for (m.StopTime st in trip.stopTimes) {
    if (st.stop.id == stop.id) {
      res = st;
      // Tries to find the first stoptime that has not been visited, otherwise
      // should return the last that has been visited
      if ((st.arrivalTime.isAfter(refTime) && trip.lastUpdate == null) ||
          (st.stopSequence > trip.lastSequenceDetection &&
              trip.lastUpdate != null)) {
        return st;
      }
    }
  }
  // Should never occur that res is null
  return res ?? trip.stopTimes[0];
}

class Defaults {
  static final SpinKitChasingDots loader = SpinKitChasingDots(
    color: themeData.colorScheme.primary,
    size: 50.0,
  );

  static final Gradient gradient = LinearGradient(
    colors: [
      themeData.colorScheme.primary.withAlpha(150),
      themeData.colorScheme.secondary
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    tileMode: TileMode.clamp,
  );

  static const List<BoxShadow> shadows = [
    BoxShadow(
      color: Color(0x7f9e9e9e), //color of shadow
      spreadRadius: 4, //spread radius
      blurRadius: 5, // blur radius
      offset: Offset(0, 2), // changes position of shadow
    )
  ];

  static final BorderRadius borderRadius = BorderRadius.circular(10);

  static final BoxDecoration decoration = BoxDecoration(
    gradient: Defaults.gradient,
    boxShadow: Defaults.shadows,
    borderRadius: Defaults.borderRadius,
  );

  static final ThemeData themeData = ThemeData(
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF386641),
      onPrimary: Colors.white,
      secondary: Color(0xFF6A994E),
      onSecondary: Colors.black,
      error: Color(0xFFBC4749),
      onError: Colors.white,
      surface: Color(0xFFFFFFFF),
      onSurface: Colors.black,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.playpenSans(
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        fontSize: 32.0,
      ),
      headlineMedium: GoogleFonts.playpenSans(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: 24.0,
      ),
      headlineSmall: GoogleFonts.playpenSans(
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        fontSize: 20.0,
      ),
      labelMedium:
          GoogleFonts.comme(fontStyle: FontStyle.italic, fontSize: 20.0),
      labelSmall:
          GoogleFonts.comme(fontStyle: FontStyle.italic, fontSize: 16.0),
      bodyLarge: GoogleFonts.comme(
        fontSize: 15,
      ),
      bodyMedium: GoogleFonts.comme(
        fontSize: 14,
      ),
    ),
    useMaterial3: true,
    searchBarTheme: SearchBarThemeData(
      textStyle: WidgetStateProperty.all(
        GoogleFonts.comme(
          fontSize: 15,
        ),
      ),
    ),
    iconTheme: const IconThemeData(size: 25),
  );

  static void showTrasportimusErrorSnackBar(
      BuildContext context, TransportFetchFailed state) {
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    var content = switch (state.type) {
      m.ErrorType.serviceunreachable => AwesomeSnackbarContent(
          title: loc.noDataTitle,
          message: loc.noDataErr,
          contentType: ContentType.failure,
          messageTextStyle: theme.textTheme.bodyMedium!
              .copyWith(color: theme.colorScheme.onError),
        ),
      m.ErrorType.tryAgain => AwesomeSnackbarContent(
          title: loc.noDataRetryTitle,
          message: loc.noDataRetryErr,
          contentType: ContentType.warning,
          messageTextStyle: theme.textTheme.bodyMedium!
              .copyWith(color: theme.colorScheme.onError),
        )
    };
    var snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 20),
      content: content,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showOsmErrorSnackBar(BuildContext context) {
    var theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    var content = AwesomeSnackbarContent(
      title: loc.noDataTitle,
      message: loc.noDataErr,
      contentType: ContentType.failure,
      messageTextStyle: theme.textTheme.bodyMedium!
          .copyWith(color: theme.colorScheme.onError),
    );
    var snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 20),
      content: content,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showInfoSnackBar(BuildContext context, String title, String msg) {
    var content = AwesomeSnackbarContent(
      title: title,
      message: msg,
      contentType: ContentType.help,
    );
    var snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 20),
      content: content,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Center noDataWidget(BuildContext context, void Function() onPressed) {
    ThemeData theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MingCuteIcons.mgc_unhappy_dizzy_line,
            size: 64,
            color: theme.colorScheme.error,
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(theme.colorScheme.error),
            ),
            child: Text(
              AppLocalizations.of(context)!.retry,
              style: theme.textTheme.labelSmall!
                  .copyWith(color: theme.colorScheme.onError),
            ),
          ),
        ],
      ),
    );
  }

  static Center emptyResultWidget(BuildContext context) {
    ThemeData theme = Theme.of(context);
    var loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MingCuteIcons.mgc_puzzled_line,
            size: 64,
            color: theme.colorScheme.secondary,
          ),
          Text(
            loc.noRouteMsg,
            style: theme.textTheme.labelMedium,
          ),
          Text(loc.noRouteHint, style: theme.textTheme.labelSmall)
        ],
      ),
    );
  }

  static ChoicePromptDelegate<T> delegatePopupDialog<T>() {
    return ChoicePrompt.delegatePopupDialog<T>(
        shape: RoundedRectangleBorder(borderRadius: Defaults.borderRadius));
  }
}
