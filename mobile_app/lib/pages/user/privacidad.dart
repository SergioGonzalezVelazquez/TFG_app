import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tfg_app/pages/user/privacidad.dart';

class PoliticaPrivacidad extends StatefulWidget {
  static const route = "/avisoLegal";

  _PoliticaPrivacidadState createState() => _PoliticaPrivacidadState();
}

class _PoliticaPrivacidadState extends State<PoliticaPrivacidad> {
  DateFormat formatter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget listItem(String title, String content) {
    return new Row(
      children: [
        Icon(
          Icons.donut_large,
          size: 6,
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          title + ":",
          style:
              Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: 0.7),
        ),
        SizedBox(
          width: 6,
        ),
        Text(
          content,
          style:
              Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: 0.7),
        )
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.07, vertical: height * 0.01),
      child: ListView(
        children: <Widget>[
          Text(
            "RESPONSABLE",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          listItem("Identidad", "STOPMiedo"),
          listItem("Responsable", "Sergio González Velázquez"),
          listItem("Correo Electrónico", "sergio.gonzalez29@alu.uclm.es"),
          listItem("Teléfono", "664205678"),
          listItem(
              "Domicilio social", "Bolaños de Calarava, 13260, Ciudad Real"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            "FINALIDADES",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            "En cumplimiento de lo dispuesto en el Reglamento Europeo 2016/679 General de Protección de Datos, te informamos de que trataremos los datos que nos facilitas para:",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "CATEGORÍAS DE DATOS",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "PLAZO DE CONSERVACIÓN",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            "STOPMiedo conservará los datos personales de los usuarios únicamente durante el tiempo necesario para la realización de las finalidades para las que fueron recogidos, mientras no revoque los consentimientos otorgados. Posteriormente, en caso de ser necesario, mantendrá la información bloqueada durante los plazos legalmente establecidos.",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "DESTINATARIOS",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            "Tus datos podrán ser accedidos por aquellos proveedores que prestan servicios a STOPMiedo, tales como servicios de alojamiento, herramientas de marketing y sistemas de contenido u otros profesionales, cuando dicha comunicación sea necesaria normativamente, o para la ejecución de los servicios contratados.",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            "STOPMiedo, ha suscrito los correspondientes contratos de encargo de tratamiento con cada uno de los proveedores que prestan servicios a STOPMiedo, con el objetivo de garantizar que dichos proveedores tratarán tus datos de conformidad con lo establecido en la legislación vigente.",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            "También podrán ser cedidos a las Fuerzas y Cuerpos de Seguridad del Estado en los casos que exista una obligación legal.",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Política de Privacidad'),
      ),
      body: _buildPage(context),
    );
  }
}
