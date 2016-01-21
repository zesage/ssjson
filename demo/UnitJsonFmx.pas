unit UnitJsonFmx;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox,
  FMX.SpinBox, System.DateUtils, System.JSON, System.Rtti, ssjson,
  ssjsonreflect, XSuperObject, Data.DBXJSONReflect;

const
  SSSJSON = 'SSJSON';
  SDBXJSON = 'DBXJSON';
  SXSUPEROBJECT = 'XSuperObject';

type
  TForm1 = class(TForm)
    mmo1: TMemo;
    exp1: TExpander;
    btnCreateParse: TButton;
    btn2: TButton;
    btn3: TButton;
    btnAccessBrowse: TButton;
    btnPath: TButton;
    btnJsonPath: TButton;
    btnObjectSet: TButton;
    SpinBox1: TSpinBox;
    lbl1: TLabel;
    btnArraySet: TButton;
    btnObjectGet: TButton;
    btnArrayGet: TButton;
    btnParseJson: TButton;
    btnAsJson: TButton;
    lbl2: TLabel;
    btnAddDelete: TButton;
    btnExtractClone: TButton;
    btnMarshal: TButton;
    btnUnmarshal: TButton;
    procedure btnCreateParseClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure btnJsonPathClick(Sender: TObject);
    procedure btnObjectSetClick(Sender: TObject);
    procedure SpinBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnArraySetClick(Sender: TObject);
    procedure btnObjectGetClick(Sender: TObject);
    procedure btnArrayGetClick(Sender: TObject);
    procedure btnParseJsonClick(Sender: TObject);
    procedure btnAsJsonClick(Sender: TObject);
    procedure btnMarshalClick(Sender: TObject);
    procedure btnUnmarshalClick(Sender: TObject);
    procedure btnAccessBrowseClick(Sender: TObject);
    procedure btnAddDeleteClick(Sender: TObject);
    procedure btnExtractCloneClick(Sender: TObject);
  private
    { Private declarations }
    FDuration: DWORD;
    FTimerTimes: DWORD;
    FTimerStart: DWORD;
    FTimerEnd: DWORD;
    FTimerFinish: DWORD;
    FTimerElapse: DWORD;
    procedure TimerStart; inline;
    procedure TimerStop; inline;
    function TimeOut: Boolean; inline;
    procedure CheckTime(const name, desc: string);
    procedure LogString(const value: string);
    procedure LogText(const value: string);
  public
    { Public declarations }
  end;

type
  TAddress = record
    FStreet: String;
    FCity: String;
    FCode: String;
    FCountry: String;
    FDescription: TStringList;
  end;

  TPerson = class
  private
    [JsonName('personName')] FName: string;
    FSex: Char;
    FHeight: Integer;
    FWeight: Double;
    FCash: Currency;
    [JsonISO8601]
    FBirthDate: TDateTime;
    FNumbers: set of 1..10;
    FAddress: TAddress;
    FRetired: boolean;
    [JsonName('-')]FParent: TPerson;
    FChildren: array of TPerson;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddChild(kid: TPerson);
  end;

const SJsonPerson =  ''
  + '{' + SLineBreak
  + '  "personName": "John Doe",' + SLineBreak
  + '  "FSex": "M",' + SLineBreak
  + '  "FHeight": 167,' + SLineBreak
  + '  "FWeight": 63.00125,' + SLineBreak
  + '  "FCash": 98765.6789,' + SLineBreak
  + '  "FBirthDate": "1983-06-28T13:58:56.035+08:00",' + SLineBreak
  + '  "FAddress": {' + SLineBreak
  + '    "FStreet": "62 Peter St",' + SLineBreak
  + '    "FCity": "TO",' + SLineBreak
  + '    "FCode": "1334566",' + SLineBreak
  + '    "FCountry": "",' + SLineBreak
  + '    "FDescription": [' + SLineBreak
  + '      "Driving directions: exit 84 on highway 66",' + SLineBreak
  + '      "Entry code: 31415"' + SLineBreak
  + '    ]' + SLineBreak
  + '  },' + SLineBreak
  + '  "FRetired": false,' + SLineBreak
  + '  "FChildren": [' + SLineBreak
  + '    {' + SLineBreak
  + '      "personName": "Jane Doe",' + SLineBreak
  + '      "FSex": "F",' + SLineBreak
  + '      "FHeight": 125,' + SLineBreak
  + '      "FWeight": 28.8,' + SLineBreak
  + '      "FCash": 899,' + SLineBreak
  + '      "FBirthDate": "2008-11-05T09:35:46.023+08:00",' + SLineBreak
  + '      "FAddress": {' + SLineBreak
  + '        "FStreet": "62 Peter St",' + SLineBreak
  + '        "FCity": "TO",' + SLineBreak
  + '        "FCode": "1334566",' + SLineBreak
  + '        "FCountry": "",' + SLineBreak
  + '        "FDescription": [' + SLineBreak
  + '          "Driving directions: exit 84 on highway 66",' + SLineBreak
  + '          "Entry code: 31415"' + SLineBreak
  + '        ]' + SLineBreak
  + '      },' + SLineBreak
  + '      "FRetired": false' + SLineBreak
  + '    },' + SLineBreak
  + '    {' + SLineBreak
  + '      "personName": "Jake Doe",' + SLineBreak
  + '      "FSex": "M",' + SLineBreak
  + '      "FHeight": 80,' + SLineBreak
  + '      "FWeight": 20.33,' + SLineBreak
  + '      "FCash": 533.99,' + SLineBreak
  + '      "FBirthDate": "2012-03-20T14:20:55.032+08:00",' + SLineBreak
  + '      "FAddress": {' + SLineBreak
  + '        "FStreet": "62 Peter St",' + SLineBreak
  + '        "FCity": "TO",' + SLineBreak
  + '        "FCode": "1334566",' + SLineBreak
  + '        "FCountry": "",' + SLineBreak
  + '        "FDescription": [' + SLineBreak
  + '          "Driving directions: exit 84 on highway 66",' + SLineBreak
  + '          "Entry code: 31415"' + SLineBreak
  + '        ]' + SLineBreak
  + '      },' + SLineBreak
  + '      "FRetired": false' + SLineBreak
  + '    }' + SLineBreak
  + '  ]' + SLineBreak
  + '}';

const
  SAMPLE_JSON_1 = ''// from http://json.org/example.html
  + '{' + SLineBreak
  + '  "glossary": {' + SLineBreak
  + '    "title": "example glossary",' + SLineBreak
  + '    "GlossDiv": {' + SLineBreak
  + '      "title": "S",' + SLineBreak
  + '      "GlossList": {' + SLineBreak
  + '        "GlossEntry": {' + SLineBreak
  + '          "ID": "SGML",' + SLineBreak
  + '          "SortAs": "SGML",' + SLineBreak
  + '          "GlossTerm": "Standard Generalized Markup Language",' + SLineBreak
  + '          "Acronym": "SGML",' + SLineBreak
  + '          "Abbrev": "ISO 8879:1986",' + SLineBreak
  + '          "GlossDef": {' + SLineBreak
  + '            "para": "A meta-markup language, used to create markup languages such as DocBook.",' + SLineBreak
  + '            "GlossSeeAlso": [' + SLineBreak
  + '              "GML",' + SLineBreak
  + '              "XML"' + SLineBreak
  + '            ]' + SLineBreak
  + '          },' + SLineBreak
  + '          "GlossSee": "markup"' + SLineBreak
  + '        }' + SLineBreak
  + '      }' + SLineBreak
  + '    }' + SLineBreak
  + '  }' + SLineBreak
  + '}';

type
  TGlossary = packed record
    glossary: record
      title: string;
      GlossDiv: record
        title: string;
        GlossList: record
          GlossEntry: record
            ID, SortAs, GlossTerm, Acronym, Abbrev: string;
            GlossDef: record
              para: string;
              GlossSeeAlso: array of string;
            end;
            GlossSee: string;
          end;
        end;
      end;
    end;
  end;

  TGlossary2 = class
  public
    glossary: record
      title: string;
      GlossDiv: record
        title: string;
        GlossList: record
          GlossEntry: record
            ID, SortAs, GlossTerm, Acronym, Abbrev: string;
            GlossDef: record
              para: string;
              GlossSeeAlso: array of string;
            end;
            GlossSee: string;
          end;
        end;
      end;
    end;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
{$R *.iPad.fmx IOS}
{$R *.Windows.fmx MSWINDOWS}

{ TPerson }

procedure TPerson.AddChild(kid: TPerson);
begin
  SetLength(FChildren, Length(FChildren)+1);
  FChildren[Length(FChildren)-1]:= kid;
end;

constructor TPerson.Create;
begin
  FAddress.FDescription:= TStringList.Create;
end;

destructor TPerson.Destroy;
var
  kid: TPerson;
begin
  for kid in FChildren do
    kid.Free;
  SetLength(FChildren, 0);
  FAddress.FDescription.Free;
  inherited;
end;

procedure TForm1.btnAccessBrowseClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  joItem: ssjson.TJSON;
  s: string;
  i: Integer;
  f: Double;
  c: Currency;
  b: Boolean;
begin
  LogString('');
  LogString('//--2. Access------------------------------------------------------');
  jo.New(SJsonPerson);
  LogString(jo['personName']); //or jo['personName'].AsString; or jo.Items['personName'].AsString;
  LogString(jo['FSex']);       //or jo['FSex'].AsString;
  LogString(jo['FHeight']);    //or jo['FHeight'].AsString;
  LogString(jo['FWeight']);    //or jo['FWeight'].AsString;
  LogString(jo['FCash']);      //or jo['FCash'].AsString;
  LogString(jo['FBirthDate']); //or jo['FBirthDate'].AsString;

  s:= jo['personName'];     //or jo['personName'].AsString;
  i:= jo['FHeight'];        //or jo['FHeight'].AsInteger;
  f:= jo['FWeight'];        //or jo['FWeight'].AsFloat;
  c:= jo['FCash'];          //or jo['FCash'].AsCurrency;
  b:= jo['FRetired'];       //or jo['FRetired'].AsBoolean;
  LogString(Format('name:%s, height:%d, weight:%f, cash:%f, retired:%s', [s, i, f, c, SJSONBool[b]]));

  LogString('--- Access array ---');
  LogString(jo['FAddress']['FDescription'][0]);
  LogString(jo['FAddress']['FDescription'][1]);
  LogString(jo['FChildren'][0]['personName']);
  LogString(jo['FChildren'][1]['personName']); //or jo.Items['FChildren'].Items[1].Items['personName'].AsString;

  LogString('--- Browsing object properties by enumerator ---');
  for joItem in jo do
    LogString(joItem);

  LogString('--- Browsing object properties by index ---');
  for i := 0 to jo.Count -1 do
    LogString(jo.Pairs[i].Value);

  LogString('--- Browsing array items by enumerator ---');
  for joItem in jo['FChildren'] do
    LogString(joItem['personName']);

  LogString('--- Browsing array items by index ---');
  for i := 0 to jo['FChildren'].Count -1 do
    LogString(jo['FChildren'][i]['personName']);

  jo.Clear;
end;

procedure TForm1.btnAddDeleteClick(Sender: TObject);
var
  jo: ssjson.TJSON;
begin
  LogString('');
  LogString('//-- Add & Modify -----------------------------------------------');
  jo.New;

  jo[0] := 'John';
  jo[1] := 'Doe';
  jo[3] := 'M';
  jo[4] := 167;
  jo[7] := 63.00125;
  LogString(jo.AsJSON);  //Output: ["John","Doe",null,"M",167,null,null,63.00125]

  jo['personName']['First'] := 'John';
  jo['personName']['Last'] := 'Doe';
  LogString(jo.AsJSON);  //Output: {"personName":{"First":"John","Last":"Doe"}}

  jo['personName'] := 'John Doe';
  LogString(jo.AsJSON);  //Output: {"personName":"John Doe"}

  jo['FChildren'][0]['personName'] := 'Jane Doe';
  jo['FChildren'][1]['personName'] := 'Jake Doe';
  LogString(jo.AsJSON);  //Output: {"personName":"John Doe","FChildren":[{"personName":"Jane Doe"},{"personName":"Jake Doe"}]}

  jo.Clear;
  with jo do
  begin
    Add('personName', 'John Doe');
    Add('FHeight', 167);
    Add('FWeight', 63.00125);
  end;
  with jo['Interests'] do
  begin
    Add('cooking');
    Add('tennis');
    Add('swimming');
  end;
  LogString(jo.AsJSON);  //Output: {"personName":"John Doe","FHeight":167,"FWeight":63.00125,"Interests":["cooking","tennis","swimming"]}
  jo.Clear;


  LogString('');
  LogString('--- Delete ---');
  jo.New('{"personName":"John Doe","FHeight":167,"FChildren":["Jane Doe","Jake Doe"]}');
  LogString(jo.AsJSON);

  jo['FChildren'].Delete(1);
  LogString(jo.AsJSON); //Output: {"personName":"John Doe","FHeight":167,"FChildren":["Jane Doe"]}
  jo['FChildren'].Delete(0);
  LogString(jo.AsJSON); //Output: {"personName":"John Doe","FHeight":167,"FChildren":[]}

  LogString('');
  jo.Delete('FHeight');
  LogString(jo.AsJSON);  //Output: {"personName":"John Doe","FChildren":[]}
  jo.Delete('FChildren');
  LogString(jo.AsJSON);  //Output: {"personName":"John Doe"}

  jo.Clear;
end;

procedure TForm1.btnCreateParseClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  p: PChar;
begin
  LogString('');
  LogString('//--1. Create & Parse----------------------------------------------');
  jo.New('{"ÐÕÃû":"John Doe","age":32}');        //Zero-initialize and parse json (does not release the Memory)
  LogString(jo['ÐÕÃû']);                            // Output: John Doe
  LogString(jo['age']);                             // Output: 32
  jo.Clear;                                      //Clear and free memory


  LogString('');
  jo.New;                                    //Initialize (zero the variable only, does not call the Clear to release Memory)
  jo['name']:= 'Jane Doe';
  jo['age']:= 8;
  LogString(jo.AsJSON);                         //Output: {"name":"Jane Doe","age":8}

  jo.AsJSON:= '{"name":"Jake Doe","age":4}'; //Clear and parse json
  LogString(jo.AsJSONIndent);                   //Format the json text with Indent, default two spaces
  LogString(jo.AsJSONIndent(#9));               //Format the json text with TAB char
  jo.Clear;                                  //Clear and release the Memory

  LogString('');
  p:= PChar(SAMPLE_JSON_1);
  jo.New(p);                                 //Parse from a null-terminated string
  LogString(jo.AsJSON);
  jo.Clear;
end;

procedure TForm1.btnExtractCloneClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  jo2: ssjson.TJSON;
begin
  LogString('--- Extract ---');
  jo.New('{"personName":"John Doe","FHeight":167,"FChildren":["Jane Doe","Jake Doe"]}');
  jo2.New('{"personName":"Aiden Doe","FHeight":173}');
  jo2['FChildren']:= jo.Extract('FChildren');
  LogString(jo.AsJSON);   //Output: {"personName":"John Doe","FHeight":167}
  LogString(jo2.AsJSON);  //Output: {"personName":"Aiden Doe","FHeight":173,"FChildren":["Jane Doe","Jake Doe"]}

  LogString('');
  jo.Clear;
  jo:= jo2['FChildren'].Extract(0);
  LogString(jo.AsJSON);   //Output: "Jane Doe"
  LogString(jo2.AsJSON);  //Output: {"personName":"Aiden Doe","FHeight":173,"FChildren":["Jake Doe"]}
  jo2.Clear;
  jo.Clear;

  LogString('--- Clone ---');
  jo.New('{"personName":"John Doe","FHeight":167,"FChildren":["Jane Doe","Jake Doe"]}');
  jo2.New('{"personName":"Aiden Doe","FHeight":173}');
  jo2['FChildren']:= jo['FChildren'].Clone;
  LogString(jo.AsJSON);   //Output: {"personName":"John Doe","FHeight":167,"FChildren":["Jane Doe","Jake Doe"]}
  LogString(jo2.AsJSON);  //Output: {"personName":"Aiden Doe","FHeight":173,"FChildren":["Jane Doe","Jake Doe"]}
  jo.Clear;

  LogString('');
  jo:= jo2['FChildren'].Clone;
  LogString(jo.AsJSON);   //Output: ["Jane Doe","Jake Doe"]
  jo2.Clear;
  jo.Clear;
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  person: TPerson;
  kid: TPerson;
  addr: TAddress;
  jo: ssjson.TJSON;
  mar: ssjsonreflect.TJSONMarshal;
begin
  LogString('');
  LogString('//-- Marshal a record ------------------------------------------');
  addr.FStreet := '62 Peter St';
  addr.FCity := 'TO';
  addr.FCode := '1334566';
  addr.FDescription:= TStringList.Create;
  addr.FDescription.Add('Driving directions: exit 84 on highway 66');
  addr.FDescription.Add('Entry code: 31415');
  jo:= TJSON.Marshal(addr);
  LogText(jo.AsJSONIndent());
  jo.Clear;
  addr.FDescription.Free;

  LogString('');
  LogString('//-- Marshal an object -----------------------------------------');
  person := TPerson.Create;
  person.FName := 'John Doe';
  person.FSex := 'M';
  person.FHeight := 167;
  person.FWeight := 63.00125;
  person.FCash := 98765.6789;
  person.FBirthDate:= EncodeDateTime(1983, 06, 28, 13, 58, 56, 35);
  person.FRetired := False;
  person.FParent := nil;
  person.FAddress.FStreet := '62 Peter St';
  person.FAddress.FCity := 'TO';
  person.FAddress.FCode := '1334566';
  person.FAddress.FDescription.Add('Driving directions: exit 84 on highway 66');
  person.FAddress.FDescription.Add('Entry code: 31415');

  kid := TPerson.Create;
  kid.FName := 'Jane Doe';
  kid.FSex := 'F';
  kid.FHeight := 125;
  kid.FWeight := 28.8;
  kid.FCash := 899.0;
  kid.FBirthDate:= EncodeDateTime(2008, 11, 05, 09, 35, 46, 23);
  kid.FRetired := False;
  kid.FParent := person;
  kid.FAddress.FStreet := '62 Peter St';
  kid.FAddress.FCity := 'TO';
  kid.FAddress.FCode := '1334566';
  kid.FAddress.FDescription.Add('Driving directions: exit 84 on highway 66');
  kid.FAddress.FDescription.Add('Entry code: 31415');
  person.AddChild(kid);

  kid := TPerson.Create;
  kid.FName := 'Jake Doe';
  kid.FSex := 'M';
  kid.FHeight := 80;
  kid.FWeight := 20.33;
  kid.FCash := 533.99;
  kid.FBirthDate:= EncodeDateTime(2012, 3, 20, 14, 20, 55, 32);
  kid.FParent := person;
  kid.FAddress.FStreet := '62 Peter St';
  kid.FAddress.FCity := 'TO';
  kid.FAddress.FCode := '1334566';
  kid.FAddress.FDescription.Add('Driving directions: exit 84 on highway 66');
  kid.FAddress.FDescription.Add('Entry code: 31415');
  person.AddChild(kid);

  jo:= TJSON.Marshal(person);
  LogText(jo.AsJSONIndent());
  jo.Clear;


  LogString('');
  LogString('//-- Marshal a type by user--------------------------------------------');
  mar := ssjsonreflect.TJSONMarshal.Create;
  mar.RegisterConverter(TypeInfo(TAddress), function(ctx: ssjsonreflect.TJSONMarshal; var jo: TJSON; const value: TValue): Boolean
  var
    addr: TAddress;
  begin
    addr:= value.AsType<TAddress>;
    with addr do
    begin
      jo['Street']:= FStreet;
      jo['City']:= FCity;
      jo['Code']:= FCode;
      jo['Country']:= FCountry;
      jo['Description']:= TJSON.Marshal(FDescription, ctx);
    end;
    Result:= True;
  end);

  jo:= TJSON.Marshal(person, mar);
  LogText(jo.AsJSONIndent());
  jo.Clear;
  mar.Free;
  person.Free;
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  person: TPerson;
  addr: TAddress;
  jo: TJSON;
  unmar: ssjsonreflect.TJSONUnMarshal;
begin
  LogString('');
  LogString('//-- Marshal a record ------------------------------------------');
  jo['FStreet'] := '62 Peter St';
  jo['FCity'] := 'TO';
  jo['FCode'] := '1334566';
  jo['FDescription'][0] := 'Driving directions: exit 84 on highway 66';
  jo['FDescription'][1] := 'Entry code: 31415';
  addr:= TJSON.Unmarshal<TAddress>(jo);
  LogText(TJSON.MarshalIndent(addr));
  addr.FDescription.Free;
  jo.Clear;

  LogString('');
  LogString('//-- Marshal an object------------------------------------------');
  jo['personName'] := 'John Doe';
  jo['FSex'] := 'M';
  jo['FHeight'] := 167;
  jo['FWeight'] := 63.00125;
  jo['FCash'] := 98765.6789;
  jo['FBirthDate'] := DelphiDateTimeToISO8601Date(EncodeDateTime(1983, 06, 28, 13, 58, 56, 35));
  jo['FRetired'] := False;
  jo['FAddress']['FStreet'] := '62 Peter St';
  jo['FAddress']['FCity'] := 'TO';
  jo['FAddress']['FCode'] := '1334566';
  jo['FAddress']['FDescription'][0] := 'Driving directions: exit 84 on highway 66';
  jo['FAddress']['FDescription'][1] := 'Entry code: 31415';

  jo['FChildren'][0]['personName'] := 'Jane Doe';
  jo['FChildren'][0]['FSex'] := 'F';
  jo['FChildren'][0]['FHeight'] := 125;
  jo['FChildren'][0]['FWeight'] := 28.8;
  jo['FChildren'][0]['FCash'] := 899.0;
  jo['FChildren'][0]['FBirthDate'] := DelphiDateTimeToISO8601Date(EncodeDateTime(2008, 11, 05, 09, 35, 46, 23));
  jo['FChildren'][0]['FRetired'] := False;
  jo['FChildren'][0]['FAddress']['FStreet'] := '62 Peter St';
  jo['FChildren'][0]['FAddress']['FCity'] := 'TO';
  jo['FChildren'][0]['FAddress']['FCode'] := '1334566';
  jo['FChildren'][0]['FAddress']['FDescription'][0] := 'Driving directions: exit 84 on highway 66';
  jo['FChildren'][0]['FAddress']['FDescription'][1] := 'Entry code: 31415';

  jo['FChildren'][1]['personName'] := 'Jake Doe';
  jo['FChildren'][1]['FSex'] := 'M';
  jo['FChildren'][1]['FHeight'] := 80;
  jo['FChildren'][1]['FWeight'] := 20.33;
  jo['FChildren'][1]['FCash'] := 533.99;
  jo['FChildren'][1]['FBirthDate'] := DelphiDateTimeToISO8601Date(EncodeDateTime(2012, 3, 20, 14, 20, 55, 32));
  jo['FChildren'][1]['FAddress']['FStreet'] := '62 Peter St';
  jo['FChildren'][1]['FAddress']['FCity'] := 'TO';
  jo['FChildren'][1]['FAddress']['FCode'] := '1334566';
  jo['FChildren'][1]['FAddress']['FDescription'][0] := 'Driving directions: exit 84 on highway 66';
  jo['FChildren'][1]['FAddress']['FDescription'][1] := 'Entry code: 31415';

  person:= TJSON.Unmarshal<TPerson>(jo);
  LogText(TJSON.MarshalIndent<TPerson>(person));
  person.Free;


  LogString('');
  LogString('//-- Marshal a type by user--------------------------------------------');
  unmar:= ssjsonreflect.TJSONUnMarshal.Create;
  unmar.RegisterReverter(TypeInfo(TAddress), function(ctx: ssjsonreflect.TJSONUnmarshal; const jo: TJSON; var Value: TValue): Boolean
  var
    addr: TAddress;
  begin
    addr:= value.AsType<TAddress>;
    with addr do
    begin
      FStreet:= jo['FStreet'];
      FCity:= jo['FCity'];
      FCode:= jo['FCode'];
      FCountry:= jo['FCountry'];
      TJSON.Unmarshal(FDescription, jo['FDescription'], ctx);
    end;
    Value:= TValue.From<TAddress>(addr);
    Result:= True;
  end);
  person:= TJSON.Unmarshal<TPerson>(jo, unmar);
  LogText(TJSON.MarshalIndent<TPerson>(person));
  jo.Clear;
  unmar.Free;
  person.Free;
end;


procedure TForm1.btnPathClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  value: ssjson.TJSON;
begin
  LogString('');
  LogString('//-- Path ------------------------------------------------------');
  jo.New(SAMPLE_JSON_1);
  LogString(jo.Paths['glossary.title']);  //Output: "example glossary"
  LogString(jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]']);  //Output: "GML"

  jo.Paths['glossary.title']:= 'An example glossary';
  jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]']:= 'ABC';
  LogString(jo.Paths['glossary.title']);  //Output: "An example glossary"
  LogString(jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]']);  //Output: "ABC"

  LogString('ContainsPath "GlossSeeAlso[0]": ' + SJSONBool[jo.ContainsPath('glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]')]);
  LogString('ContainsPath "GlossSeeAlso[2]": ' + SJSONBool[jo.ContainsPath('glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]')]);
  LogString('ContainsPath "GlossSeeAlso[4]":: ' + SJSONBool[jo.ContainsPath('glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[4]')]);

  if jo.ContainsPath('glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]', @value) then
  begin
    value.AsString:= 'DEF';
    LogString(jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]']);  //Output: "DEF"

    value:= 'GHI'; //this will not change "GlossSeeAlso[2]"
    LogString(jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[2]']);  //Output: "DEF"
    LogString(value.AsJSON); //Output: "GHI"
    value.Clear;
  end;
  jo.Clear;

  LogString('');
  LogString('//-- Contains ------------------------------------------------------');
  jo.New(SAMPLE_JSON_1);
  if jo['glossary'].Contains('title') then // return true
    LogString(jo['glossary']['title']);  //Output: "example glossary"
  if jo['glossary'].Contains('name') then // return false
    LogString(jo['glossary']['name']);
  if jo['glossary'].Contains('GlossDiv', @value) then
  begin
    LogString(value['title']);  //Output: "S"
    if value.Contains('GlossList', @value) then
      if value.Contains('GlossEntry', @value) then
      begin
        LogString(value['GlossTerm']);  //Output: "Standard Generalized Markup Language"
      end;
  end;
  jo.Clear;
end;

procedure TForm1.btnArrayGetClick(Sender: TObject);
var
  s: string;
  i: Integer;
  count: Integer;
  jo: ssjson.TJSON;
  dja: TJSONArray;
  xsa: xsuperobject.ISuperArray;
begin
  LogString('');
  LogString('//--Array Get------------------------------------------------------');
  count:= 100;
  for i := 0 to count -1 do
  begin
    jo[i]:= IntToStr(i);
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= jo[i].AsString;
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SSSJSON, 's := json[i].AsString');
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= jo[i];
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SSSJSON, 's := json[i]');
  jo.Clear;


  dja := TJSONArray.Create;
  for i := 0 to count -1 do
  begin
    dja.Add(IntToStr(i));
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= dja.Items[i].Value;
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SDBXJSON, 's := json.Items[i].Value');
  dja.Free;


  xsa := xsuperobject.TSuperArray.Create;
  for i := 0 to count -1 do
  begin
    xsa.S[i]:= IntToStr(i);
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= xsa.S[i];
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 's := json.S[i]');
  xsa:= nil;
end;

procedure TForm1.btnArraySetClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  dja: TJSONArray;
  xsa: xsuperobject.ISuperArray;
begin
  LogString('');
  LogString('//--Array Set------------------------------------------------------');

  TimerStart;
  while not TimeOut do
    jo[FTimerTimes].AsString:= 'One';
  TimerStop;
  CheckTime(SSSJSON, 'json[i].AsString:= ''One''');
  jo.Clear;

  TimerStart;
  while not TimeOut do
    jo[FTimerTimes]:= 'One';
  TimerStop;
  CheckTime(SSSJSON, 'json[i]:= ''One''');
  jo.Clear;

  dja := TJSONArray.Create;
  TimerStart;
  while not TimeOut do
  begin
    dja.Add('One');
  end;
  TimerStop;
  CheckTime(SDBXJSON, 'json.Add(''One'')');
  dja.Free;

  xsa := xsuperobject.TSuperArray.Create;
  TimerStart;
  while not TimeOut do
  begin
    xsa.S[FTimerTimes]:= 'One';
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json.S[i]:= ''One''');
  xsa:= nil;
end;

procedure TForm1.btnObjectGetClick(Sender: TObject);
var
  s: string;
  i: Integer;
  count: Integer;
  jo: ssjson.TJSON;
  djo: TJSONObject;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--Object Get-----------------------------------------------------');
  count:= 100;
  for i := 0 to count -1 do
  begin
    s:= IntToStr(i);
    jo[s]:= s;
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= jo[IntToStr(i)].AsString;
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SSSJSON, 's := json["i"].AsString');
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= jo[IntToStr(i)];
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SSSJSON, 's := json["i"]');
  jo.Clear;


  djo := TJSONObject.Create;
  for i := 0 to count -1 do
  begin
    s:= IntToStr(i);
    djo.AddPair(s, s);
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= djo.Values[IntToStr(i)].Value;
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SDBXJSON, 's := json.Values["i"].Value');
  djo.Free;


  xso := xsuperobject.TSuperObject.Create;
  for i := 0 to count -1 do
  begin
    s:= IntToStr(i);
    xso.S[s]:= s;
  end;
  i:= 0;
  TimerStart;
  while not TimeOut do
  begin
    s:= xso.S[IntToStr(i)];
    Inc(i);
    if i >= count then i := 0;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 's := json.S["i"]');
  xso:= nil;
end;

procedure TForm1.btnObjectSetClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  djo: TJSONObject;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--Object Set-----------------------------------------------------');
  TimerStart;
  while not TimeOut do
    jo[IntToStr(FTimerTimes)].AsString:= 'One';
  TimerStop;
  CheckTime(SSSJSON, 'json["i"].AsString:= ''One''');
  jo.Clear;

  TimerStart;
  while not TimeOut do
    jo[IntToStr(FTimerTimes)]:= 'One';
  TimerStop;
  CheckTime(SSSJSON, 'json["i"]:= ''One''');
  jo.Clear;


  djo := TJSONObject.Create;
  TimerStart;
  while not TimeOut do
  begin
    djo.AddPair(IntToStr(FTimerTimes), 'One');
  end;
  TimerStop;
  CheckTime(SDBXJSON, 'json.AddPair("i", ''One'')');
  djo.Free;


  xso := xsuperobject.TSuperObject.Create;
  TimerStart;
  while not TimeOut do
  begin
    xso.S[IntToStr(FTimerTimes)]:= 'One';
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json.S["i"]:= ''One''');
  xso:= nil;
end;

procedure TForm1.btnParseJsonClick(Sender: TObject);
var
  jo: ssjson.TJSON;
  djo: TJSONObject;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--Parse JSON-----------------------------------------------------');
  TimerStart;
  while not TimeOut do
  begin
    jo.AsJSON:= SAMPLE_JSON_1;
//    jo.New(SAMPLE_JSON_1);
//    jo.Clear;
  end;
  TimerStop;
  CheckTime(SSSJSON, 'json.AsJSON:= SAMPLE_JSON_1');
  jo.Clear;


  TimerStart;
  while not TimeOut do
  begin
    djo := TJSONObject.ParseJSONValue(SAMPLE_JSON_1) as TJSONObject;
    djo.Free;
  end;
  TimerStop;
  CheckTime(SDBXJSON, 'TJSONObject.ParseJSONValue(SAMPLE_JSON_1)');


  TimerStart;
  while not TimeOut do
  begin
    xso:= xsuperobject.SO(SAMPLE_JSON_1);
    xso:= nil;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'xsuperobject.SO(SAMPLE_JSON_1)');
end;

procedure TForm1.btnUnmarshalClick(Sender: TObject);
var
  gloss: TGlossary;
  gloss2: TGlossary2;
  jo: ssjson.TJSON;
//  djv: TJSONValue;
//  djm: TJSONMarshal;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--UnMarshal Record-----------------------------------------------');
  jo.New(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    gloss:= TJSON.Unmarshal<TGlossary>(jo);
  end;
  TimerStop;
  CheckTime(SSSJSON, 'gloss:= TJSON.Unmarshal<TGlossary>(jo)');
  jo.Clear;


  xso:= SO(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    Finalize(gloss);
    gloss:= TSuperRecord<TGlossary>.FromJSON(xso);
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'gloss:= TSuperRecord<TGlossary>.FromJSON(xso)');
  xso:= nil;

  LogString('');
  LogString('//--UnMarshal Class------------------------------------------------');
  jo.New(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    gloss2:= TJSON.Unmarshal<TGlossary2>(jo);
    gloss2.Free;
  end;
  TimerStop;
  CheckTime(SSSJSON, 'gloss2:= TJSON.Unmarshal<TGlossary2>(jo)');
  jo.Clear;

//  djum := TJSONUnMarshal.Create;
//  djv := TJSONObject.ParseJSONValue(SAMPLE_JSON_1);
//  TimerStart;
//  while not TimeOut do
//  begin
//    gloss2:= djum.Unmarshal(djv) as TGlossary2;
//    gloss2.Free;
//  end;
//  TimerStop;
//  CheckTime(SDBXJSON, 'gloss2:= djum.Unmarshal(djv) as TGlossary2');
//  djv.Free;
//  djum.Free;

  xso:= SO(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    gloss2:= TGlossary2.FromJson(xso);
    gloss2.Free;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'gloss2:= TGlossary2.FromJson(xso)');
  xso:= nil;
end;

procedure TForm1.btnAsJsonClick(Sender: TObject);
var
  s: string;
  jo: ssjson.TJSON;
  djo: TJSONObject;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--AsJSON---------------------------------------------------------');
  jo.New(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    s:= jo.AsJSON;
  end;
  TimerStop;
  CheckTime(SSSJSON, 'json.AsJSON:= SAMPLE_JSON_1');
  jo.Clear;


  djo := TJSONObject.ParseJSONValue(SAMPLE_JSON_1) as TJSONObject;
  TimerStart;
  while not TimeOut do
  begin
    s:= djo.ToString;
  end;
  TimerStop;
  CheckTime(SDBXJSON, 'TJSONObject.ParseJSONValue(SAMPLE_JSON_1)');
  djo.Free;


  xso:= xsuperobject.SO(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    s:= xso.AsJSON;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'xsuperobject.SO(SAMPLE_JSON_1)');
  xso:= nil;
end;

procedure TForm1.btnJsonPathClick(Sender: TObject);
var
  s: string;
  jo: ssjson.TJSON;
  xso: xsuperobject.ISuperObject;
  djv: System.JSON.TJSONValue;
begin
  LogString('');
  LogString('//--- Path -----------------------------------------------------');
  TimerStart;
  while not TimeOut do
    s:= jo.Paths['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]'].AsString;
  TimerStop;
  CheckTime(SSSJSON, 'json.Path[''glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]''].AsString');

   djv := TJSONObject.ParseJSONValue(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
    s:= djv.GetValue<string>('glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]');
  TimerStop;
  CheckTime(SDBXJSON, 'json.GetValue(''glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]'') as TJSONString).Value');
  djv.Free;

  xso := xsuperobject.SO(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
    s:= xso['glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]'].AsString;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json[''glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]''].AsString');
  xso:= nil;



  LogString('');
  LogString('//-----------------------------------------------------------------');

  TimerStart;
  while not TimeOut do
    s:= jo['glossary']['GlossDiv']['GlossList']['GlossEntry']['GlossDef']['GlossSeeAlso'][0].AsString;
  TimerStop;
  CheckTime(SSSJSON, 'json[''glossary''][''GlossDiv''][''GlossList''][''GlossEntry''][''GlossDef''][''GlossSeeAlso''][0].AsString');
  jo.Clear;

  djv := TJSONObject.ParseJSONValue(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
    s:= (((((((djv as TJSONObject) .
      GetValue('glossary') as TJSONObject).
      GetValue('GlossDiv') as TJSONObject).
      GetValue('GlossList') as TJSONObject).
      GetValue('GlossEntry') as TJSONObject).
      GetValue('GlossDef') as TJSONObject).
      GetValue('GlossSeeAlso') as TJSONArray).Items[0].Value;
  TimerStop;
  CheckTime(SDBXJSON, 'json.GetValue(''glossary'').GetValue(''GlossDiv'').GetValue(''GlossList'').GetValue(''GlossEntry'').GetValue(''GlossDef'').GetValue(''GlossSeeAlso'').Items[0].Value');
  djv.Free;

  xso := xsuperobject.SO(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
    s:= xso.O['glossary'].O['GlossDiv'].O['GlossList'].O['GlossEntry'].O['GlossDef'].A['GlossSeeAlso'].S[0];
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json.O[''glossary''].O[''GlossDiv''].O[''GlossList''].O[''GlossEntry''].O[''GlossDef''].A[''GlossSeeAlso''].S[0]');
  xso:= nil;
end;

procedure TForm1.btnMarshalClick(Sender: TObject);
var
  gloss: TGlossary;
  gloss2: TGlossary2;
  jo: ssjson.TJSON;
  djv: System.JSON.TJSONValue;
  djm: TJSONMarshal;
  djum: TJSONUnMarshal;
  xso: xsuperobject.ISuperObject;
begin
  LogString('');
  LogString('//--Marshal Record-------------------------------------------------');
  gloss:= TJSON.Unmarshal<TGlossary>(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    jo := TJSON.Marshal<TGlossary>(gloss);
    jo.Clear;
  end;
  TimerStop;
  CheckTime(SSSJSON, 'json:= TJSON.Marshal<TGlossary>(gloss)');

  Finalize(gloss);
  gloss:= TSuperRecord<TGlossary>.FromJSON(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    xso:= TSuperRecord<TGlossary>.AsJSONObject(gloss);
    xso:= nil;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json:= TSuperRecord<TGlossary>.AsJSONObject(gloss)');

  LogString('');
  LogString('//--Marshal Class--------------------------------------------------');
  gloss2:= TJSON.Unmarshal<TGlossary2>(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    jo := TJSON.Marshal<TGlossary2>(gloss2);
    jo.Clear;
  end;
  TimerStop;
  CheckTime(SSSJSON, 'json:= TJSON.Marshal<TGlossary>(gloss2)');
  gloss2.Free;

  djm := TJSONMarshal.Create;
  djum := TJSONUnMarshal.Create;
//  djv := TJSONObject.ParseJSONValue(SAMPLE_JSON_1);
//  gloss2:= djum.Unmarshal(djv) as TGlossary2;
//  djv.Free;
  gloss2:= TJSON.Unmarshal<TGlossary2>(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    djv:= djm.Marshal(gloss2);
    djv.Free;
  end;
  TimerStop;
  CheckTime(SDBXJSON, 'json:= TJSONMarshal.Marshal(gloss2)');
  gloss2.Free;
  djm.Free;
  djum.Free;

  gloss2:= TGlossary2.FromJson(SAMPLE_JSON_1);
  TimerStart;
  while not TimeOut do
  begin
    xso:= gloss2.AsJSONObject;
    xso:= nil;
  end;
  TimerStop;
  CheckTime(SXSUPEROBJECT, 'json:= TSuperRecord<TGlossary>.AsJSONObject(gloss2)');
  gloss2.Free;
end;

procedure TForm1.SpinBox1Change(Sender: TObject);
begin
  FDuration:= Trunc(SpinBox1.Value);
end;

procedure TForm1.LogString(const value: string);
begin
  mmo1.Lines.Add(value);
  mmo1.GoToTextEnd;
end;

procedure TForm1.LogText(const value: string);
var
  list: TStringList;
begin
  list:= TStringList.Create;
  list.Text:= value;
  mmo1.Lines.AddStrings(list);
  list.Free;
  mmo1.GoToTextEnd;
end;

procedure TForm1.CheckTime(const name, desc: string);
begin
  mmo1.Lines.Add(Format('%20s: %.0n times   %.0n milliseconds   %.0n/s :  %s', [name, FTimerTimes+0.0, FTimerElapse+0.0, FTimerTimes / (FTimerElapse / 1000) , desc]));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FDuration:= Trunc(SpinBox1.Value);
end;

function TForm1.TimeOut: Boolean;
begin
  Result:= TThread.GetTickCount >= FTimerEnd;
  Inc(FTimerTimes);
end;

procedure TForm1.TimerStart;
begin
  FTimerTimes:= 0;
  FTimerStart:= TThread.GetTickCount;
  FTimerEnd:= FTimerStart + FDuration;
end;

procedure TForm1.TimerStop;
begin
  FTimerFinish:= TThread.GetTickCount;
  FTimerElapse:= FTimerFinish - FTimerStart;
end;


end.
