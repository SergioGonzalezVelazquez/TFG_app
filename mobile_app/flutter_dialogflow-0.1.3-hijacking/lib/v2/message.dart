// Custom
class TextDialogflow {
  String text;
  DateTime timestamp;

  TextDialogflow(Map response) {
    this.text = response['text'][0];
    this.timestamp = DateTime.now();
  }
}

class ListTextDialogflow {
  List<String> listText = [];

  ListTextDialogflow(Map response) {
    List<dynamic> listText = response['text']['text'];
    listText.forEach((element) => this.listText.add(element));
  }
}

class SuggestionDialogflow {
  String text;
  String value;

  SuggestionDialogflow(Map suggestion) {
    this.text = suggestion['text'];
    this.value = suggestion['value'];
  }
}

class ListSuggestionDialogflow {
  List<SuggestionDialogflow> listSuggestions = [];

  ListSuggestionDialogflow(Map response) {
    List<dynamic> list = response['suggestions'];
    list.forEach(
        (element) => this.listSuggestions.add(SuggestionDialogflow(element)));
  }
}

class ImageDialogflow {
  String imageUri;
  String accessibilityText;

  ImageDialogflow(Map response) {
    this.imageUri = response['imageUri'];
    this.accessibilityText = response['accessibilityText'];
  }
}

class QuickReplies {
  String title;
  List<String> quickReplies = [];

  QuickReplies(Map response) {
    this.title = response['quickReplies']['title'];
    List<dynamic> listQuickReplies = response['quickReplies']['quickReplies'];
    listQuickReplies.forEach((element) => this.quickReplies.add(element));
  }
}

class ButtonDialogflow {
  String text;
  String postback;

  ButtonDialogflow(Map response) {
    text = response['text'];
    postback = response['postback'];
  }
}

class CardDialogflow {
  String title;
  String subtitle;
  String imageUri;
  List<ButtonDialogflow> buttons = [];

  CardDialogflow(Map response) {
    this.title = response['card']['title'];
    this.subtitle = response['card']['subtitle'];
    this.imageUri = response['card']['imageUri'];
    List<dynamic> listButtons = response['card']['buttons'];
    for (int i = 0; i < listButtons.length; i++) {
      ButtonDialogflow b = new ButtonDialogflow(listButtons[i]);
      buttons.add(b);
    }
  }
}

class SimpleResponse {
  String textToSpeech;
  String ssml;
  String displayText;
  DateTime timestamp;

  SimpleResponse(Map response) {
    this.textToSpeech = response['textToSpeech'];
    this.ssml = response['ssml'];
    this.displayText = response['displayText'];
    this.timestamp = DateTime.now();
  }
}

class SimpleResponses {
  List<SimpleResponse> simpleResponses = [];

  SimpleResponses(Map response) {
    List<dynamic> listSimpleResponse =
        response['simpleResponses']['simpleResponses'];
    for (int i = 0; i < listSimpleResponse.length; i++) {
      SimpleResponse b = new SimpleResponse(listSimpleResponse[i]);
      simpleResponses.add(b);
    }
  }
}

class BasicCardDialogflow {
  String title;
  String subtitle;
  String formattedText;
  ImageDialogflow image;
  List<dynamic> buttons;

  BasicCardDialogflow(Map response) {
    this.title = response['basicCard']['title'];
    this.subtitle = response['basicCard']['subtitle'];
    this.formattedText = response['basicCard']['formattedText'];
    this.image = new ImageDialogflow(response['basicCard']['image']);
    this.buttons = response['basicCard']['buttons'];
  }
}

class ItemCarousel {
  dynamic info;
  String title;
  String description;
  ImageDialogflow image;
  ItemCarousel(Map item) {
    this.info = item['info'];
    this.title = item['title'];
    this.description = item['description'];
    this.image = new ImageDialogflow(item['image']);
  }
}

class CarouselSelect {
  List<ItemCarousel> items = [];
  CarouselSelect(Map response) {
    List<dynamic> list = response['carouselSelect']['items'];
    for (var i = 0; i < list.length; i++) {
      items.add(new ItemCarousel(list[i]));
    }
  }
}

class TypeMessage {
  String platform;
  String type;
  TypeMessage(Map message) {
    this.platform = message['platform'];
    //Extendido para soportar todos los tipos de dialogFlow
    if(message.containsKey('payload')){
      message = message['payload'];
    }

    if (message.containsKey('text')) {
      this.type = 'text';
    } else if (message.containsKey('suggestions')) {
      this.type = 'suggestion';
    } else if (message.containsKey('basicCard')) {
      this.type = 'basicCard';
    } else if (message.containsKey('simpleResponses')) {
      this.type = 'simpleResponses';
    }
  }
}
