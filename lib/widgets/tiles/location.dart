import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:osm_api/model/location.dart';

final class LocationTile extends StatelessWidget {
  const LocationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        color: Colors.teal,
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

final class LocationExpanded extends StatelessWidget {
  final Location location;
  final Function(double, double) onTap;

  const LocationExpanded(this.location, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    var addr = location.address;
    var subtitle = '';
    if (addr.road != null) {
      subtitle += '${addr.road!}, ';
    }
    if (addr.village != null &&
        addr.municipality != null &&
        addr.countyCode != null) {
      subtitle +=
          '${addr.village}, ${addr.municipality} (${addr.countyCode}), ';
    } else if (addr.village != null && addr.municipality != null) {
      subtitle += '${addr.village}, ${addr.municipality}, ';
    } else if (addr.village != null && addr.countyCode != null) {
      subtitle += '${addr.village} (${addr.countyCode}), ';
    } else if (addr.countyCode != null && addr.county != null) {
      subtitle += "${addr.county}, ";
    }
    if (addr.state != null) {
      subtitle += addr.state!;
    }
    if (subtitle.endsWith(', ')) {
      subtitle.substring(0, subtitle.length - 2);
    }

    return ListTile(
      leading: LocationTile(),
      title: Text(
        location.name,
        overflow: TextOverflow.clip,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      horizontalTitleGap: 5,
      isThreeLine: true,
      onTap: () => onTap(location.lat, location.lon),
    );
  }
}
