import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskStatusLegend extends StatelessWidget {
  const TaskStatusLegend({Key? key}) : super(key: key);

  Widget _coloredDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: [
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Color(0xff0CC302)),
              Text(
                'Completed Task',
                style:
                    GoogleFonts.poppins(color: Color(0xff2E3A59), fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Color(0xFFFE0B0B)),
              Text(
                'Terminated Task',
                style:
                    GoogleFonts.poppins(color: Color(0xff2E3A59), fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Color(0xff0B7CFE)),
              Text(
                'In Progress',
                style:
                    GoogleFonts.poppins(color: Color(0xff2E3A59), fontSize: 14),
              ),
            ],
          ),
        ),
        Container(
          width: 150,
          child: Row(
            children: [
              _coloredDot(Color(0xffFFCF0F)),
              Text(
                'To Do',
                style:
                    GoogleFonts.poppins(color: Color(0xff2E3A59), fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
