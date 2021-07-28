import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:house_input/providers/location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/ulti.dart';
// import 'package:cosmosdb/cosmosdb.dart';

class Filter extends StatefulWidget {
  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  @override
  Widget build(BuildContext context) {}
}

class ButtonReset extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black.withOpacity(0.7)),
        child: Text('Reset'),
        onPressed: () =>
            LocationProvider.of(context, listen: false).level1 = null,
      );
}

class Level1 extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Consumer<LocationProvider>(
        builder: (context, data, _) => ElevatedButton(
            onPressed: () => _select1(context, data),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Colors.black.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                  // color: Colors.black.withOpacity(0.8),
                  // gradient: LinearGradient(
                  //   colors: [
                  //     //Colors.indigo[200],
                  //     Color(0xFF0050AC)
                  //   ],
                  // ),
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.center,
                child: Text(data.level1?.name ?? 'Tap to select region.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
            )),
      );
  void _select1(BuildContext context, LocationProvider data) async {
    final selected = await _select<dvhcvn.Level1>(context, dvhcvn.level1s);
    if (selected != null) data.level1 = selected;
  }
}

// class Level1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext _) => Consumer<LocationProvider>(
//         builder: (context, data, _) => ElevatedButton(
//             onPressed: () => _select1(context, data),
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.zero,
//               // primary: Color(0xFF0050AC),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: Ink(
//               decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   // gradient: LinearGradient(
//                   //   colors: [
//                   //     //Colors.indigo[200],
//                   //     Color(0xFF0050AC)
//                   //   ],
//                   // ),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Container(
//                 height: 50.0,
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 alignment: Alignment.center,
//                 child: Text(data.level1?.name ?? 'Tap to select region.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     )),
//               ),
//             )),
//       );

//   void _select1(BuildContext context, LocationProvider data) async {
//     final selected = await _select<dvhcvn.Level1>(context, dvhcvn.level1s);
//     if (selected != null) data.level1 = selected;
//   }
// }

// class Level2 extends StatefulWidget {
//   @override
//   _Level2State createState() => _Level2State();
// }

// class _Level2State extends State<Level2> {
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     final data = LocationProvider.of(context);
//     if (data.latestChange == 1) {
//       // user has just selected a level 1 entity,
//       // automatically trigger bottom sheet for quick level 2 selection
//       WidgetsBinding.instance
//           .addPostFrameCallback((_) => _select2(context, data));
//     }
//   }

//   @override
//   Widget build(BuildContext _) => Consumer<LocationProvider>(
//         builder: (context, data, _) => ElevatedButton(
//             onPressed: () => _select2(context, data),
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.zero,
//               // primary: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//             ),
//             child: Ink(
//               decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   // gradient: LinearGradient(
//                   //   colors: [
//                   //     Colors.indigo[200],
//                   //     Color(0xFF9354B9),
//                   //   ],
//                   // ),
//                   borderRadius: BorderRadius.circular(10)),
//               child: Container(
//                 height: 50.0,
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 alignment: Alignment.center,
//                 child: Text(
//                   data.level2?.name ?? 'Tap to select district.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                   ),
//                   // overflow: TextOverflow.ellipsis,
//                   // maxLines: 2,
//                 ),
//               ),
//             )),
//       );

//   void _select2(BuildContext context, LocationProvider data) async {
//     final level1 = data.level1;
//     if (level1 == null) return;

//     final selected = await _select<dvhcvn.Level2>(
//       context,
//       level1.children,
//       header: level1.name,
//     );
//     if (selected != null) data.level2 = selected;
//   }
// }

class Level2 extends StatefulWidget {
  @override
  _Level2State createState() => _Level2State();
}

class _Level2State extends State<Level2> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data = LocationProvider.of(context);
    if (data.latestChange == 1) {
      // user has just selected a level 1 entity,
      // automatically trigger bottom sheet for quick level 2 selection
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _select2(context, data));
    }
  }

  @override
  Widget build(BuildContext _) => Consumer<LocationProvider>(
        builder: (context, data, _) => ElevatedButton(
            onPressed: () => _select2(context, data),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              primary: Colors.black.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Colors.indigo[200],
                  //     Color(0xFF9354B9),
                  //   ],
                  // ),
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width * 0.5,
                alignment: Alignment.center,
                child: Text(
                  data.level2?.name ?? 'Tap to select district.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  // overflow: TextOverflow.ellipsis,
                  // maxLines: 2,
                ),
              ),
            )),
      );

  void _select2(BuildContext context, LocationProvider data) async {
    final level1 = data.level1;
    if (level1 == null) return;

    final selected = await _select<dvhcvn.Level2>(
      context,
      level1.children,
      header: level1.name,
    );
    if (selected != null) data.level2 = selected;
  }
}

class Level3 extends StatefulWidget {
  @override
  _Level3State createState() => _Level3State();
}

class _Level3State extends State<Level3> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final data = LocationProvider.of(context);
    if (data.latestChange == 2) {
      // user has just selected a level 2 entity,
      // automatically trigger bottom sheet for quick level 3 selection
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _select3(context, data));
    }
  }

  @override
  Widget build(BuildContext _) => Consumer<LocationProvider>(
      builder: (context, data, _) => ElevatedButton(
          onPressed: () => _select3(context, data),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            primary: Colors.black.withOpacity(0.8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Ink(
            decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   colors: [
                //     Colors.indigo[200],
                //     Color(0xFF9354B9),
                //   ],
                // ),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width * 0.5,
              alignment: Alignment.center,
              child: Text(
                data.level3?.name ?? 'Tap to select ward.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                // overflow: TextOverflow.ellipsis,
                // maxLines: 2,
              ),
            ),
          )));

  void _select3(BuildContext context, LocationProvider data) async {
    final level2 = data.level2;
    if (level2 == null) return;

    final selected = await _select<dvhcvn.Level3>(
      context,
      level2.children,
      header: level2.name,
    );
    if (selected != null) data.level3 = selected;
  }
}

Future<T> _select<T extends dvhcvn.Entity>(
  BuildContext context,
  List<T> list, {
  String header,
}) =>
    showModalBottomSheet<T>(
      context: context,
      builder: (_) => Column(
        children: [
          // header (if provided)
          if (header != null)
            Padding(
              child: Text(
                header,
                style: Theme.of(context).textTheme.headline6,
              ),
              padding: const EdgeInsets.all(8.0),
            ),
          if (header != null) Divider(),

          // entities
          Expanded(
            child: ListView.builder(
              itemBuilder: (itemContext, i) {
                final item = list[i];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('#${item.id}, ${item.typeAsString}'),
                  onTap: () => Navigator.of(itemContext).pop(item),
                );
              },
              itemCount: list.length,
            ),
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
