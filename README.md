<img src="mobile_app/assets/images/stop.png" align="right" height="248" />

# STOPMiedo

<p style='text-align: justify; padding-right: 13em;'> 
STOPMiedo es una herramienta que pretende ayudar a las personas que sufren amaxofobia, o miedo a conducir, a superar la ansiedad al volante, mediante la aplicación del método terapéutico de la <strong>Desensibilización Sistemática (DS)</strong>.
</p>

<p align="center" style='padding-right: 13em;'>
    <a href="https://github.com/SergioGonzalezVelazquez/TFG_app/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/SergioGonzalezVelazquez/TFG_app?style=plastic"></a>
    <a href="https://github.com/SergioGonzalezVelazquez/TFG_app/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/SergioGonzalezVelazquez/TFG_app?style=plastic"></a>
</p>

## Descripción

<p style='text-align: justify;'> 
El sistema está formado por una plataforma <em>backend</em> en <em><strong>Firebase</strong></em> y una aplicación cliente para <em>smartphone</em> desarrollada con <strong><em>Flutter</em></strong>, que guia al usuario en las diferentes fases de la terapia. 
</p>

<p style='text-align: justify;'> 
Durante las primeras sesiones de uso de la app, la persona que sufre amaxofobia tendrá que responder a un cuestionario previo y, mantener una serie de conversaciones con un terapeuta virtual (<strong>agente conversacional</strong>). Esta primera fase permite conocer el contexto o situación de origen de la amaxofobia en cada paciente concreto, lo cual es necesario para, después, poder elegir el tratamiento más apropiado para cada usuario.
</p>

<p style='text-align: justify;'> 
Dicho tratamiento consiste en la exposición, de manera progresiva, a una serie de situaciones (relacionadas con la conducción) que producen ansiedad en el usuario. El sistema, además, genera un conjunto de informes que permiten llevar un registro de los ejercicios de exposición que ha realizado el paciente, así como un control de la evolución de la ansiedad del usuario durante la exposición a cada situación temida.
</p>

<p style='text-align: justify;'> 
Teniendo en cuenta que las situaciones de ansiedad y pánico (como las que sufren las personas que padecen amaxofobia) provocan síntomas físicos como sudoración, cambios en el ritmo respiratorio, vértigos o náuseas, el sistema complementa el proceso de DS con información
del estado fisiológico de la persona sometida a terapia. Dicho estado fisiológico, se obtiene mediante mecanismos de sensorización embebidos o conectados al smartphone (<strong><em>Xiaomi Mi Band</em> 2/3</strong>).
</p>

<p style='text-align: justify;'> 
Por otro lado, el sistema también cuenta con un <strong>módulo que reconoce implícitamente eventos relacionados con la conducción</strong>, tales como el inicio y detección de la marcha, frenazos o acelerones. Esta información, combinada con el estado fisiológico del conductor, resulta muy útil para analizar el comportamiento de pacientes que sufren ansiedad durante la conducción.
</p>

<p style='text-align: justify;'> 
El esquema general de la siguiente figura representa gráficamente los diferentes componentes del sistema y las tecnologías utilizadas.
</p>

<p align="center">
	<img src="/img/esquema_general.png">
</p>


## Imágenes

### Agente conversacional

<p align="center">
  <img src="/img/device-chat1.png" width="200" > <img src="/img/device-chat4.png" width="200"> <img src="/img/device-chat7.png" width="200">
</p>


### Desensibilización Sistemática
<p align="center">
  <img src="/img/device-jerarquia1.png" width="200" > <img src="/img/device-ejercicios1.png" width="200"> <img src="/img/device-ejercicio1.png" width="200">
</p>

<p align="center">
  <img src="/img/device-expoCuest1.png" width="200" > <img src="/img/device-expoCuest4.png" width="200"> <img src="/img/device-expo12.png" width="200">
</p>


### Evolución del paciente

<p align="center">
  <img src="/img/device-informe0.png" width="200" > <img src="/img/device-informe1.png" width="200"> <img src="/img/device-informe2.png" width="200">
</p>

<p align="center">
  <img src="/img/device-informe3.png" width="200" > <img src="/img/device-progreso1.png" width="200"> <img src="/img/device-progreso5.png" width="200">
</p>

### Detección ímplicita de eventos durante la conducción

<p align="center">
  <img src="/img/device-2020-07-07-193945.png" width="200" > <img src="/img/device-pulsaciones5.png" width="200"> <img src="/img/device-autodrive-route3.png" width="200">
</p>


### Monitorización del ritmo cardíaco

<p align="center">
  <img src="/img/device-pulsaciones4.png" width="200" >  <img src="/img/device-pulsaciones10.png" width="400">
</p>


## Requisitos
<p style='text-align: justify;'> 
Los requisitos mínimos para que la aplicación de STOPMiedo funcione correctamente son:
</p>

- Dispositivo _Android 5.0_ o superior.
- Acceso a Internet para la sincronización de datos de la aplicación.
- Al menos 33.6MB de espacio disponible para la instalación de la _app_.

<p style='text-align: justify;'> 
Adicionalmente, para poder disfrutar de todas las funcionalidades que ofrece STOPMiedo, es
necesario disponer de:
</p>

- Pulsera de seguimiento de actividad física _Xiaomi Mi Band_ 2 o _Xiaomi Mi Band_ 3.
- _Bluetooth_ 4.0 o superior.

## Herramientas 
- Flutter 1.22.0 
- Dart 2.10.0
- Firebase
- Dialogflow



