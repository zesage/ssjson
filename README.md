# ssjson

This version is tested on Delphi XE and Delphi 10 (and ios).

###Parse
```pascal
var
  jo: TJSON;
begin
  jo.New('{"ÐÕÃû":"John Doe","age":32}');               //Zero-initialize and parse json
  memo1.Lines.Add(jo['ÐÕÃû']);                         // Output: John Doe
  memo1.Lines.Add(jo['age']);                          // Output: 32
  jo.Clear;                                             //Clear and free memory

  jo['name']:= 'Jane Doe';
  jo['age']:= 8;
  memo1.Lines.Add(jo.AsJSON);                           //Output: {"name":"Jane Doe","age":8}

  jo.AsJSON:= '{"name":"Jake Doe","age":4}';            //Clear and parse json
  memo1.Lines.Add(jo['name']);                          //Output: Jake Doe
  memo1.Lines.Add(jo['age']);                           //Output: 8
  jo.Clear;                                             //Clear and release the Memory
end;
```

###Access
*
```pascal
var
  jo: TJSON;
begin
  jo['menu']['id']:= 'file';
  jo['menu']['value']:= 'File';
  jo['menu']['popup']['menuitem'][0]['value']:= 'New';
  jo['menu']['popup']['menuitem'][0]['onclick']:= 'CreateNewDoc()';
  jo['menu']['popup']['menuitem'][1]['value']:= 'Open';
  jo['menu']['popup']['menuitem'][1]['onclick']:= 'OpenDoc';
  jo['menu']['popup']['menuitem'][2]['value']:= 'Close';
  jo['menu']['popup']['menuitem'][2]['onclick']:= 'CloseDoc';
  memo1.Lines.Text:= jo.AsJSONIndent();
  jo.Clear;
end;
```
Output:
```json
{
  "menu":  {
    "id":  "file",
    "value":  "File",
    "popup":  {
      "menuitem":  [
        {
          "value":  "New",
          "onclick":  "CreateNewDoc()"
        },
        {
          "value":  "Open",
          "onclick":  "OpenDoc"
        },
        {
          "value":  "Close",
          "onclick":  "CloseDoc"
        }
      ]
    }
  }
}
```
*
```pascal
var
  jo: TJSON;
  s: string;
  i: Integer;
  f: Double;
  c: Currency;
  b: Boolean;
begin
  jo['Name'] := 'John Doe';
  jo['Sex'] := 'M';
  jo['Age'] := 32;
  jo['Height'] := 167;
  jo['Weight'] := 63.00125;
  jo['Cash'] := 98765.6789;
  jo['Retired'] := False;
  jo['Address']['Street'] := '62 Peter St';
  jo['Address']['City'] := 'TO';
  jo['Address']['Code'] := '1334566';
  jo['Address']['Description'][0] := 'Driving directions: exit 84 on highway 66';
  jo['Address']['Description'][1] := 'Entry code: 31415';
  memo1.Lines.Text:= jo.AsJSONIndent();

  memo1.Lines.Add(jo['Name']);
  memo1.Lines.Add(jo['Sex']);
  memo1.Lines.Add(jo['Age']);
  memo1.Lines.Add(jo['Height']);
  memo1.Lines.Add(jo['Weight']);
  memo1.Lines.Add(jo['Cash']);
  memo1.Lines.Add(jo['Retired']);
  memo1.Lines.Add(jo['Address']['Street']);
  memo1.Lines.Add(jo['Address']['City']);
  memo1.Lines.Add(jo['Address']['Code']);
  memo1.Lines.Add(jo['Address']['Description'][0]);
  memo1.Lines.Add(jo['Address']['Description'][1]);

  s:= jo['Name'];
  i:= jo['Height'];
  f:= jo['Weight'];
  c:= jo['Cash'];
  b:= jo['Retired'];
  memo1.Lines.Add(Format('name:%s, height:%d, weight:%f, cash:%f, retired:%s', [s, i, f, c, SJSONBool[b]]));

  jo.Clear;
```
Output:
```json
{
  "Name":  "John Doe",
  "Sex":  "M",
  "Age":  32,
  "Height":  167,
  "Weight":  63.00125,
  "Cash":  98765.6789,
  "Retired":  false,
  "Address":  {
    "Street":  "62 Peter St",
    "City":  "TO",
    "Code":  "1334566",
    "Description":  [
      "Driving directions: exit 84 on highway 66",
      "Entry code: 31415"
    ]
  }
}
John Doe
M
32
167
63.00125
98765.6789
false
62 Peter St
TO
1334566
Driving directions: exit 84 on highway 66
Entry code: 31415
name:John Doe, height:167, weight:63.00, cash:98765.68, retired:false
```
###Marshal
```pascal
type
  TAddress = record
    FStreet: String;
    FCity: String;
    FCode: String;
    FCountry: String;
    FDescription: TStringList;
  end;

var
  addr: TAddress;
  jo: TJSON;
begin
  addr.FStreet := '62 Peter St';
  addr.FCity := 'TO';
  addr.FCode := '1334566';
  addr.FDescription:= TStringList.Create;
  addr.FDescription.Add('Driving directions: exit 84 on highway 66');
  addr.FDescription.Add('Entry code: 31415');
  jo:= TJSON.Marshal(addr);
  memo1.Lines.Text:= jo.AsJSONIndent;
  jo.Clear;
  addr.FDescription.Free;
end;
```
Output:
```json
{
  "FStreet":  "62 Peter St",
  "FCity":  "TO",
  "FCode":  "1334566",
  "FCountry":  "",
  "FDescription":  [
    "Driving directions: exit 84 on highway 66",
    "Entry code: 31415"
  ]
}
```
###Unmarshal
```pascal
var
  addr: TAddress;
  jo: TJSON;
begin
  jo['FStreet'] := '62 Peter St';
  jo['FCity'] := 'TO';
  jo['FCode'] := '1334566';
  jo['FDescription'][0] := 'Driving directions: exit 84 on highway 66';
  jo['FDescription'][1] := 'Entry code: 31415';
  addr:= TJSON.Unmarshal<TAddress>(jo);

  memo1.Lines.Add(addr.FStreet);
  memo1.Lines.Add(addr.FCity);
  memo1.Lines.Add(addr.FCode);
  memo1.Lines.Add(addr.FCountry);
  memo1.Lines.Add(addr.FDescription[0]);
  memo1.Lines.Add(addr.FDescription[1]);
  jo.Clear;
  addr.FDescription.Free;
end;
```
Output:
```json
62 Peter St
TO
1334566

Driving directions: exit 84 on highway 66
Entry code: 31415
```
