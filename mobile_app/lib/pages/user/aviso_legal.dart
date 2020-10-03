import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'privacidad.dart';

class AvisoLegalPage extends StatefulWidget {
  static const route = "/avisoLegal";

  _AvisoLegalPageState createState() => _AvisoLegalPageState();
}

class _AvisoLegalPageState extends State<AvisoLegalPage> {
  DateFormat formatter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            """En este espacio, el USUARIO, podrá encontrar toda la información relativa a los términos y condiciones legales que definen las relaciones entre los usuarios y nosotros como responsables de esta plataforma. Como usuario, es importante que conozcas estos términos antes de continuar tu navegación. Sergio González Velázquez. Como responsable de esta plataforma, asume el compromiso de procesar la información de nuestros usuarios y clientes con plenas garantías y cumplir con los requisitos nacionales y europeos que regulan la recopilación y uso de los datos personales de nuestros usuarios. Esta aplicación, por tanto, cumple rigurosamente con el RGPD (REGLAMENTO (UE) 2016/679 de protección de datos) y la LSSI-CE la Ley 34/2002, de 11 de julio, de servicios de la sociedad de la información y de comercio electrónico.""",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            "CONDICIONES GENERALES DE USO",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            """Las presentes Condiciones Generales regulan el uso (incluyendo el mero acceso) de las páginas de la aplicación, integrantes de la herramienta de STOPMiedo incluidos los contenidos y servicios puestos a disposición en ellas. Toda persona que acceda a la aplicación, STOPMiedo (“Usuario”) acepta someterse a las Condiciones Generales vigentes en cada momento del portal STOPMiedo.""",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Text(
            "DATOS PERSONALES QUE RECABAMOS",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Row(
            children: [
              Text("Leer "),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(
                  PoliticaPrivacidad.route,
                ),
                child: Text(
                  "Política de privacidad",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.07,
          ),
          Text(
            "COMPROMISOS Y OBLIGACIONES DE LOS USUARIOS",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            """El Usuario queda informado, y acepta, que el acceso a la presente web no supone, en modo alguno, el inicio de una relación comercial con STOPMiedo. De esta forma, el usuario se compromete a utilizar el sitio Web, sus servicios y contenidos sin contravenir la legislación vigente, la buena fe y el orden público. Queda prohibido el uso de la web, con fines ilícitos o lesivos, o que, de cualquier forma, puedan causar perjuicio o impedir el normal funcionamiento del sitio web. Respecto de los contenidos de esta web, se prohíbe:Su reproducción, distribución o modificación, total o parcial, a menos que se cuente con la autorización de sus legítimos titulares;Cualquier vulneración de los derechos del prestador o de los legítimos titulares;Su utilización para fines comerciales o publicitarios.""",
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
            "En la utilización de la web, STOPMiedo, el Usuario se compromete a no llevar a cabo ninguna conducta que pudiera dañar la imagen, los intereses y los derechos de STOPMiedo o de terceros o que pudiera dañar, inutilizar o sobrecargar el portal (indicar dominio) o que impidiera, de cualquier forma, la normal utilización de la web. No obstante, el Usuario debe ser consciente de que las medidas de seguridad de los sistemas informáticos en Internet no son enteramente fiables y que, por tanto STOPMiedo no puede garantizar la inexistencia de virus u otros elementos que puedan producir alteraciones en los sistemas informáticos (software y hardware) del Usuario o en sus documentos electrónicos y ficheros contenidos en los mismos.",
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
            "MEDIDAS DE SEGURIDAD",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            "Los datos personales comunicados por el usuario a STOPMiedo pueden ser almacenados en bases de datos automatizadas o no, cuya titularidad corresponde en exclusiva a STOPMiedo, asumiendo ésta todas las medidas de índole técnica, organizativa y de seguridad que garantizan la confidencialidad, integridad y calidad de la información contenida en las mismas de acuerdo con lo establecido en la normativa vigente en protección de datos.",
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
            "La comunicación entre los usuarios y STOPMiedo utiliza un canal seguro, y los datos transmitidos son cifrados gracias a protocolos a https, por tanto, garantizamos las mejores condiciones de seguridad para que la confidencialidad de los usuarios esté garantizada.",
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
            "DERECHOS DE PROPIEDAD INTELECTUAL E INDUSTRIAL",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            "En virtud de lo dispuesto en los artículos 8 y 32.1, párrafo segundo, de la Ley de Propiedad Intelectual, quedan expresamente prohibidas la reproducción, la distribución y la comunicación pública, incluida su modalidad de puesta a disposición, de la totalidad o parte de los contenidos de esta página web, con fines comerciales, en cualquier soporte y por cualquier medio técnico, sin la autorización de STOPMiedo. El usuario se compromete a respetar los derechos de Propiedad Intelectual e Industrial titularidad de STOPMiedo. El usuario conoce y acepta que la totalidad del sitio web, conteniendo sin carácter exhaustivo el texto, software, contenidos (incluyendo estructura, selección, ordenación y presentación de los mismos) podcast, fotografías, material audiovisual y gráficos, está protegida por marcas, derechos de autor y otros derechos legítimos, de acuerdo con los tratados internacionales en los que España es parte y otros derechos de propiedad y leyes de España. En el caso de que un usuario o un tercero consideren que se ha producido una violación de sus legítimos derechos de propiedad intelectual por la introducción de un determinado contenido en la web, deberá notificar dicha circunstancia a STOPMiedo indicando:",
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
            "Datos personales del interesado titular de los derechos presuntamente infringidos, o indicar la representación con la que actúa en caso de que la reclamación la presente un tercero distinto del interesado. Señalar los contenidos protegidos por los derechos de propiedad intelectual y su ubicación en la web, la acreditación de los derechos de propiedad intelectual señalados y declaración expresa en la que el interesado se responsabiliza de la veracidad de las informaciones facilitadas en la notificación",
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
            "POLÍTICA DE PRIVACIDAD",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline5
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.015,
          ),
          Text(
            "Responsable",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.7),
          ),
          listItem("Identidad", "STOPMiedo"),
          listItem("Responsable", "Sergio González Velázquez"),
          listItem("Correo Electrónico", "sergio.gonzalez29@alu.uclm.es"),
          listItem("Teléfono", "664205678"),
          listItem(
              "Domicilio social", "Bolaños de Calarava, 13260, Ciudad Real"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Finalidades",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            """En cumplimiento de lo dispuesto en el Reglamento Europeo 2016/679 General de Protección de Datos, te informamos de que trataremos los datos que nos facilitas para:""",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.005,
          ),
          listItem2(
              """Dar cumplimiento a las obligaciones legalmente establecidas, así como verificar el cumplimiento de las obligaciones contractuales, incluía la prevención de fraude."""),
          listItem2(
              """Cesión de datos a organismos y autoridades, siempre y cuando sean requeridos de conformidad con las disposiciones legales y reglamentarias."""),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Categorías de datos",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            """Derivada de las finalidades antes mencionadas, en STOPMiedo gestionamos las siguientes categorías de datos:""",
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
          ),
          listItem2("Datos identificativos"),
          listItem2("Metadatos de comunicaciones electrónicas"),
          listItem2("Datos biómetricos"),
          listItem2("Datos de localización"),
          listItem2(
              "No obstante, STOPMiedo podrá llevar a cabo las verificaciones para constatar este hecho, adoptando las medidas de diligencia debida que correspondan, conforme a la normativa de protección de datos"),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Plazo de conservación",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
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
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            "Destinatarios",
            textAlign: TextAlign.start,
            style: Theme.of(context)
                .textTheme
                .headline6
                .apply(fontSizeFactor: 0.7),
          ),
          Text(
            """Tus datos podrán ser accedidos por aquellos proveedores que prestan servicios a STOPMiedo, tales como servicios de alojamiento, herramientas de marketing y sistemas de contenido u otros profesionales, cuando dicha comunicación sea necesaria normativamente, o para la ejecución de los servicios contratados.""",
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
            """STOPMiedo, ha suscrito los correspondientes contratos de encargo de tratamiento con cada uno de los proveedores que prestan servicios a STOPMiedo, con el objetivo de garantizar que dichos proveedores tratarán tus datos de conformidad con lo establecido en la legislación vigente.""",
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
            """También podrán ser cedidos a las Fuerzas y Cuerpos de Seguridad del Estado en los casos que exista una obligación legal.""",
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

  Widget listItem(String title, String content) {
    return Row(
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

  Widget listItem2(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          child: Icon(
            Icons.donut_large,
            size: 6,
          ),
          padding: EdgeInsetsDirectional.only(top: 4),
        ),
        SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            content,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .apply(fontSizeFactor: 0.7),
            overflow: TextOverflow.clip,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aviso Legal y Términos de Uso'),
      ),
      body: _buildPage(context),
    );
  }
}
