unit ssjson;
(*
   Copyright 2015 Zesage

   Home: https://github.com/zesage

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*)

interface

uses
  SysUtils,
  Classes,
  Variants,
  Generics.Collections;

type
  TJSONType = (jtNull, jtBoolean, jtInteger, jtFloat, jtCurrency, jtString, jtArray, jtObject, jtJsonPtr, jtMax = $FFFF);

  PJSON = ^TJSON;

  TJSONValue = record
    case TJSONType of
      jtNull:
        (jv_null: Int64);
      jtBoolean:
        (jv_boolean: Boolean);
      jtInteger:
        (jv_integer: Int64);
      jtFloat:
        (jv_float: Double);
      jtCurrency:
        (jv_currency: Currency);
      jtString:
        (jv_string: Pointer);       //string
      jtArray:
        (jv_array: Pointer);        //TList<PJSON>
      jtObject:
        (jv_object: Pointer;        //TList<TPair<string, PJSON>>
          jv_objectdic: Pointer;);  //TDictionary<string, PJSON>
      jtJsonPtr:
        (jv_json: PJSON);
      jtMax: // for test
        (jv_PWideChar: PChar);
  end;

  TJSON = packed record
  private
    type
      TJSONPairBase<TName, TValue> = record
        Name: TName;
        Value: TValue;
      end;
  public
    type
      TJSONPair = TJSONPairBase<string, TJSON>;
      TJSONEnumerator = record
      private
        FJSON: PJSON;
        FIndex: Integer;
      public
        constructor Create(const aJson: TJSON);
        function GetCurrent: TJSON;
        function MoveNext: Boolean;
        property Current: TJSON read GetCurrent;
      end;
  private
    function GetCount: Integer;
    function GetJSONPtr: PJSON; inline;
    function GetJSONType: TJSONType;
    function GetJSONByPath(src: PChar): PJSON; overload;
    function GetAsBoolean: Boolean;
    function GetAsInteger: Int64;
    function GetAsFloat: Double;
    function GetAsCurrency: Currency;
    function GetAsString: string;
    function GetAsJSON: string; inline;
    function GetAsArray(index: Integer): TJSON;
    function GetAsObject(const name: string): TJSON;
    function GetAsPath(const aPath: string): TJSON; inline;
    function GetPair(index: Integer): TJSONPair;

    procedure SetAsBoolean(const value: Boolean);
    procedure SetAsInteger(const value: Int64);
    procedure SetAsFloat(const value: Double);
    procedure SetAsCurrency(const value: Currency);
    procedure SetAsString(const value: string);
    procedure SetAsJSON(const value: string); inline;
    procedure SetAsArray(Idx: Integer; const value: TJSON);
    procedure SetAsObject(const name: string; const value: TJSON);
    procedure SetAsPath(const aPath: string; const value: TJSON); inline;

    procedure CreateAsArray; inline;
    procedure CreateAsObject; inline;
    function ParseJSON(var src: PChar; var value: TJSON): Integer;
  public
    procedure New; overload; inline;
    function New(const json: string): Integer; overload; inline;
    function New(json: PChar): Integer; overload; inline;
    procedure Clear;
    procedure Add(const value: TJSON); overload; inline;
    procedure Add(const name: string; const value: TJSON); overload; inline;
    procedure Delete(index: Integer); overload;
    procedure Delete(const name: string); overload;
    function Extract(index: Integer): TJSON; overload;
    function Extract(const name: string): TJSON; overload;
    function Clone: TJSON;
    function Contains(index: Integer; value: PJSON = nil): Boolean; overload;
    function Contains(const name: string; value: PJSON = nil): Boolean; overload;
    function ContainsPath(const path: string; value: PJSON = nil): Boolean;
    function GetEnumerator: TJSONEnumerator;

    function IsNull: Boolean;
    function IsBoolean: Boolean;
    function IsInteger: Boolean;
    function IsFloat: Boolean;
    function IsCurrency: Boolean;
    function IsString: Boolean;
    function IsArray: Boolean;
    function IsObject: Boolean;

    procedure AsNull; inline;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsInteger: Int64 read GetAsInteger write SetAsInteger;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsCurrency: Currency read GetAsCurrency write SetAsCurrency;
    property AsString: string read GetAsString write SetAsString;
    property AsJSON: string read GetAsJSON write SetAsJSON;
    function AsJSONIndent(const Indent: string = '  '): string; overload;
    property JSONPtr: PJSON read GetJSONPtr;
    property JSONType: TJSONType read GetJSONType;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TJSON read GetAsArray write SetAsArray; default;
    property Items[const Name: string]: TJSON read GetAsObject write SetAsObject; default;
    property Paths[const Path: string]: TJSON read GetAsPath write SetAsPath;
    property Pairs[Index: Integer]: TJSONPair read GetPair;

    class operator Implicit(const value: Boolean): TJSON; // inline;
    class operator Implicit(const value: Integer): TJSON; // inline;
    class operator Implicit(const value: Cardinal): TJSON; // inline;
    class operator Implicit(const value: Int64): TJSON; // inline;
    class operator Implicit(const value: Single): TJSON; // inline;
    class operator Implicit(const value: Double): TJSON; // inline;
    class operator Implicit(const value: Extended): TJSON; // inline;
    class operator Implicit(const value: Currency): TJSON; // inline;
//    class operator Implicit(const Value: AnsiString): TJSON; // inline; cross-platform no support AnsiString
    class operator Implicit(const value: string): TJSON; // inline;
    class operator Implicit(const value: Variant): TJSON;

    class operator Implicit(const value: TJSON): Boolean; inline;
    class operator Implicit(const value: TJSON): Integer; inline;
    class operator Implicit(const value: TJSON): Cardinal; inline;
    class operator Implicit(const value: TJSON): Int64; inline;
    class operator Implicit(const value: TJSON): Single; inline;
    class operator Implicit(const value: TJSON): Double; inline;
    class operator Implicit(const value: TJSON): Extended; inline;
    class operator Implicit(const value: TJSON): Currency; inline;
    class operator Implicit(const value: TJSON): string; inline;
    // class operator Implicit(const Value: TJSON): Variant; inline;
    class operator Equal(const a, b: TJSON): Boolean;
    class operator NotEqual(const a, b: TJSON): Boolean;
    class operator Add(const a: TJSON; b: Char): string;
    class operator Add(const a: Char; const b: TJSON): string;
  private
    FJSONType: TJSONType;
    FJSONValue: TJSONValue;
  end;


const
  NULL: TJSON = (FJSONType: jtNull; FJSONValue: (jv_null: 0));

  SJSONBool: array [Boolean] of string = ('false', 'true');
  SJSONNull = 'null';

implementation

{ TJSONEnumerator }

constructor TJSON.TJSONEnumerator.Create(const aJson: TJSON);
begin
  FIndex:= -1;
  FJSON:= aJson.JSONPtr;
end;

function TJSON.TJSONEnumerator.GetCurrent: TJSON;
begin
  case FJSON.FJSONType of
    jtArray:
      begin
        Result.FJSONType := jtJsonPtr;
        Result.FJSONValue.jv_json := TList<PJSON>(FJSON.FJSONValue.jv_array).Items[FIndex];
      end;
    jtObject:
      begin
        Result.FJSONType := jtJsonPtr;
        Result.FJSONValue.jv_json := TList<TPair<string, PJSON>>(FJSON.FJSONValue.jv_object).Items[FIndex].Value;
      end;
  else
    Result.New;
  end;
end;

function TJSON.TJSONEnumerator.MoveNext: Boolean;
begin
  case FJSON.FJSONType of
    jtArray:
      begin
        Inc(FIndex);
        Result := FIndex < TList<PJSON>(FJSON.FJSONValue.jv_array).Count;
      end;
    jtObject:
      begin
        Inc(FIndex);
        Result := FIndex < TList<TPair<string, PJSON>>(FJSON.FJSONValue.jv_object).Count;
      end;
  else
    Result := False;
  end;
end;

{ TJSON }

procedure TJSON.New;
begin
//  ZeroMemory(@Self, SizeOf(TJSON));
  FJSONType := jtNull;
  FJSONValue.jv_null:= 0;
end;

function TJSON.New(const json: string): Integer;
var
  src: PChar;
begin
  New;
  src:= PChar(json);
  Result:= ParseJSON(src, Self);
end;

function TJSON.New(json: PChar): Integer;
begin
  New;
  Result:= ParseJSON(json, Self);
end;

procedure TJSON.Clear;
var
  i: Integer;
  value: PJSON;
  pair: TPair<string, PJSON>;
begin
  case FJSONType of
    jtJsonPtr:
      FJSONValue.jv_json^.Clear;
    jtString:
      Finalize(string(FJSONValue.jv_string));
    jtArray:
    begin
      with TList<PJSON>(FJSONValue.jv_array) do
      begin
        for i := 0 to Count -1 do
        begin
          value:= Items[i];
          if value <> nil then
          begin
            Items[i].Clear;
            FreeMem(value);
          end;
        end;
        Free;
      end;
    end;
    jtObject:
      begin
        TDictionary<string, PJSON>(FJSONValue.jv_objectdic).Free;
        with TList<TPair<string, PJSON>>(FJSONValue.jv_object) do
        begin
          for i := 0 to Count -1 do
          begin
            pair:= Items[i];
            Finalize(pair.Key);
            pair.Value.Clear;
            FreeMem(pair.Value);
          end;
          Free;
        end;
      end;
  end;
  New;
end;

function TJSON.IsNull: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsNull
  else
    Result := FJSONType = jtNull;
end;

function TJSON.IsBoolean: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsBoolean
  else
    Result := FJSONType = jtBoolean;
end;

function TJSON.IsInteger: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsInteger
  else
    Result := FJSONType = jtInteger;
end;

function TJSON.IsFloat: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsFloat
  else
    Result := FJSONType = jtFloat;
end;

function TJSON.IsCurrency: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsCurrency
  else
    Result := FJSONType = jtCurrency;
end;

function TJSON.IsString: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsString
  else
    Result := FJSONType = jtString;
end;

function TJSON.IsArray: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsArray
  else
    Result := FJSONType = jtArray;
end;

function TJSON.IsObject: Boolean;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.IsObject
  else
    Result := FJSONType = jtObject;
end;

function TJSON.AsJSONIndent(const indent: string = '  '): string;
var
  buffer: PChar;
  buffSize: Integer;
  buffCurr: Integer;

  function Max(const A, B: Integer): Integer;
  begin
    if A > B then
      Result := A
    else
      Result := B;
  end;

  procedure Append(value: PChar; len: Integer); overload;
  begin
    len:= len * SizeOf(Char);
    if buffCurr + len > buffSize then
    begin
      buffSize:= Max(buffSize * 2, buffSize + len);
      ReallocMem(buffer, buffSize);
    end;

    Move(value^, PChar(Integer(buffer) + buffCurr)^, len);
    Inc(buffCurr, len);
  end;

  procedure Append(const value: string); inline; overload;
  begin
    Append(PChar(value), Length(value));
  end;

  procedure Append(const value: string; repeatCount: Integer); inline; overload;
  var
    i: Integer;
    len: Integer;
  begin
    len:= Length(value);
    for i := 1 to repeatCount do
      Append(PChar(value), len);
  end;

  procedure EscapedString(const value: string);
  var
    s: string;
    len: Integer;
    pStart: PChar;
    pCurr: PChar;
  begin
    if value = '' then Exit;

    len:= Length(value);
    pStart:= PChar(value);
    pCurr:= pStart;
    for len := 0 to len - 1 do
    begin
      case pCurr^ of
        '"':
          s := '\"';
        '\':
          s := '\\';
        '/':
          s := '\/';
        #8:
          s := '\b';
        #12:
          s := '\f';
        #10:
          s := '\n';
        #13:
          s := '\r';
        #9:
          s := '\t';
        #0:
          s := '\u0000';
      else
        Inc(pCurr);
        Continue;
      end;

      Append(pStart, pCurr - pStart);
      Append(s);
      Inc(pCurr);
      pStart := pCurr;
    end;

    Append(pStart, pCurr - pStart);
  end;

  procedure BuildJSonText(const indent: string; level: Integer; json: PJSON);
  var
    I: Integer;
    pair: TPair<string, PJSON>;
  begin
    if json = nil then
      Append(SJSONNull)
    else
      case json^.FJSONType of
        jtNull:
          Append(SJSONNull);
        jtJsonPtr:
          BuildJSonText(indent, level, json.FJSONValue.jv_json);
        jtBoolean:
          Append(SJSONBool[json.FJSONValue.jv_boolean]);
        jtInteger:
          Append(IntToStr(json.FJSONValue.jv_integer));
        jtFloat:
          Append(FloatToStr(json.FJSONValue.jv_float));
        jtCurrency:
          Append(CurrToStr(json.FJSONValue.jv_currency));
        jtString:
          begin
            Append('"');
            EscapedString(string(json.FJSONValue.jv_string));
            Append('"');
          end;
        jtArray:
          begin
            Append('[');
            with TList<PJSON>(json.FJSONValue.jv_array) do
            if Count > 0 then
            begin
              Inc(level);
              for I := 0 to Count - 1 do
              begin
                if I > 0 then
                  Append(',');
                if indent <> '' then
                begin
                  Append(#13#10);
                  Append(indent, level);
                end;
                BuildJSonText(indent, level, Items[I]);
              end;
              Dec(level);
              if indent <> '' then
              begin
                Append(#13#10);
                Append(indent, level);
              end;
            end;
            Append(']');
          end;
        jtObject:
          begin
            Append('{');
            with TList<TPair<string, PJSON>>(json.FJSONValue.jv_object) do
            if Count > 0 then
            begin
              Inc(level);
              for I := 0 to Count - 1 do
              begin
                pair:= Items[I];
                if I > 0 then
                  Append(',');
                if indent <> '' then
                begin
                  Append(#13#10);
                  Append(indent, level);
                end;
                Append('"');
                EscapedString(pair.Key);
                Append('":');
                if indent <> '' then
                  Append(indent);
                BuildJSonText(indent, level, pair.Value);
              end;
              Dec(level);
              if indent <> '' then
              begin
                Append(#13#10);
                Append(indent, level);
              end;
            end;
            Append('}');
          end;
      end;
  end;

begin
  buffSize:= $500;
  GetMem(buffer, buffSize);
  try
    buffCurr:= 0;
    BuildJSonText(indent, 0, @Self);
    PChar(Integer(buffer) + buffCurr)^:= #0;
    Result:= buffer;
  finally
    FreeMem(buffer);
  end;
end;

function TJSON.ParseJSON(var src: PChar; var value: TJSON): Integer;
const
  HexDecimalConvert: array[Byte] of Byte = (
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {00-0F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {10 0F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {20-2F}
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  0,  0,  0,  0,  0,  0, {30-3F}
     0, 10, 11, 12, 13, 14, 15,  0,  0,  0,  0,  0,  0,  0,  0,  0, {40-4F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {50-5F}
     0, 10, 11, 12, 13, 14, 15,  0,  0,  0,  0,  0,  0,  0,  0,  0, {60-6F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {70-7F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {80-8F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {90-9F}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {A0-AF}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {B0-BF}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {C0-CF}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {D0-DF}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, {E0-EF}
     0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0);{F0-FF}

  procedure trimLeftP(var src: PChar);
  begin
    while True do
      case src^ of
        #1..' ': Inc(src);
        '/':
        begin
          Inc(src);
          case src^ of
            '/':
            begin
              Inc(src);
              while True do
                case src^ of
                  #0: Exit;
                  #10, #13:
                  begin
                    Inc(src);
                    Break;
                  end;
                else
                  Inc(src);
                end;
            end;
            '*':
            begin
              Inc(src);
              while True do
                case src^ of
                  #0: Exit;
                  '*':
                  begin
                    Inc(src);
                    if src^ = '/' then
                    begin
                      Inc(src);
                      Break;
                    end;
                  end;
                else
                  Inc(src);
                end;
            end;
          end;
        end;
      else
        Break;
      end;
  end;

  function ParseNumber(var src: PChar; var jo: TJSON): Integer;
  var
    p: PChar;
    pNumber: PChar;
    pExponent: PChar;
    pDot: PChar;

    s: string;
    len: Integer;
    vInt: Int64;
    vCur: Currency;
    vFloat: Double;
  begin
    p:= src;
    if (p^ = '0') and ((p[1] = 'x') or (p[1] = 'X')) then
    begin
      Inc(p, 2);
      pNumber:= p;
      while True do
        case p^ of
          'A'..'Z', 'a'..'z', '0'..'9':
            Inc(p);
          #0, #9, #10, #13, ' ', ',', ';', '}', ']', '/':
            Break;
        else
          Exit(-Integer(p));
        end;
      if p - pNumber > 0 then
      begin
        len:= p - src;
        SetLength(s, len);
        Move(src^, PChar(s)^, len * SizeOf(Char));
        if TryStrToInt64(s, vInt) then  //As Hex
        begin
          jo.AsInteger:= vInt;
          src:= p;
          Exit(Integer(p));
        end;
      end;
      Exit(-Integer(p));
    end;

    pNumber:= nil;
    pExponent:= nil;
    pDot:= nil;
    while True do
    begin
      case p^ of
        '0'..'9':
          pNumber:= p;
        '+', '-':
          if (pNumber <> nil) and (pExponent <> p -1) then Exit(-Integer(p));
        '.':
          if (pDot = nil) and (pExponent = nil) then
            pDot:= p
          else
            Exit(-Integer(p));
        'E', 'e':
          if ((pNumber <> nil) or (pDot <> nil)) and (pExponent = nil) then
            pExponent:= p
          else
            Exit(-Integer(p));
        #0, #9, #10, #13, ' ', ',', ';', '}', ']', '/':
          Break;
      else
        Exit(-Integer(p));
      end;
      Inc(p);
    end;

    if (pNumber = nil) and (pDot = nil) then Exit(-Integer(p));

    len:= p - src;
    SetLength(s, len);
    Move(src^, PChar(s)^, len * SizeOf(Char));
    if pExponent = nil then
    begin
      if pDot = nil then
      begin
        if TryStrToInt64(s, vInt) then  //As Integer
        begin
          jo.AsInteger:= vInt;
          src:= p;
          Exit(Integer(p));
        end;
      end else
      if pNumber - pDot <= 4 then
      begin
        if TryStrToCurr(s, vCur) then  //As Currency
        begin
          jo.AsCurrency:= vCur;
          src:= p;
          Exit(Integer(p));
        end;
      end else
      if TryStrToFloat(s, vFloat) then  //As Float
      begin
        jo.AsFloat:= vFloat;
        src:= p;
        Exit(Integer(p));
      end;
    end else
      if pNumber > pExponent then
      begin
        if TryStrToFloat(s, vFloat) then  //As Exponent
        begin
          jo.AsFloat:= vFloat;
          src:= p;
          Exit(Integer(p));
        end;
      end;
    Exit(-Integer(p));
  end;

  function ParseString(var src: PChar): string;
  var
    s: string;
    c: Char;
    quote: Char;
  begin
    Result:= '';
    if (src^ = '"') or (src^ = '''') then
    begin
      quote:= src^;
      Inc(src);
    end else
      quote:= #0;

    c:= ' ';
    s := '';
    while True do
    begin
      case src^ of
        #0:
          Break;
        #1..#31, ',', ';', ':', '=', '[', ']', '{', '}':
        begin
          if quote = #0 then  //unquote text end
            Break;
          c:= src^;
        end;
        '/':
        begin
          c:= src^;
          if quote = #0 then  //unquote text comment
            if (src[1] = '*') or (src[1] = '/') then
              Break;
        end;
        '"', '''':
        begin
          if src^ = quote then
          begin
            Inc(src);
            Break;
          end else
            c:= src^;
        end;
        '\':
        begin
          Inc(src);
          case src^ of
            #0:
              Exit;
            'b':
              c:= #$08;
            't':
              c:= #$09;
            'n':
              c:= #$0A;
            'f':
              c:= #$0C;
            'r':
              c:= #$0D;
            'u':
            begin
              c:= src^;
              case src[1] of
                '0'..'9', 'A'..'F', 'a'..'f':
                  case src[2] of
                    '0'..'9', 'A'..'F', 'a'..'f':
                      case src[3] of
                        '0'..'9', 'A'..'F', 'a'..'f':
                          case src[4] of
                            '0'..'9', 'A'..'F', 'a'..'f':
                            begin
                              c:= Char((HexDecimalConvert[Ord(src[1])] shl 12) or
                                (HexDecimalConvert[Ord(src[2])] shl 8) or
                                (HexDecimalConvert[Ord(src[3])] shl 4) or
                                 HexDecimalConvert[Ord(src[4])]);
                              Inc(src, 4);
                            end
                          end;
                      end;
                  end;
              end;
            end;
          else
            c:= src^;
          end;
        end
      else
        c:= src^;
      end;
      Inc(src);
      s:= s + c;
    end;

    if quote = #0 then  //unquote text
      Result:= TrimRight(s)
    else
      Result:= s;
  end;

  function ParseObject(var src: PChar; var jo: TJSON): Integer;
  var
    key: string;
    value: TJSON;
  begin
    if (src^ <> '{') then
      Exit(-Integer(src));
    Inc(src);
    trimLeftP(src);

    key := '';
    while True do
    begin
      case src^ of
        #0:
          Exit(-Integer(src));
        '}':  // An empty json object
           Exit(Integer(src));
      else
        key:= ParseString(src);
      end;

      trimLeftP(src);
      if (src^ = ':') or (src^ = '=') then
        Inc(src)
      else
        Exit(-Integer(src));

      value.New;
      Result:= ParseJSON(src, value);
      jo.Add(key, value);
      if Result < 0 then Exit;

      trimLeftP(src);
      case src^ of
        ';', ',':
        begin
          Inc(src);
          trimLeftP(src);
          if src^ = '}' then
          begin
            Inc(src);
            Exit(Integer(src));
          end;
        end;

        '}':
        begin
          Inc(src);
          Exit(Integer(src));
        end
      else
        Exit(-Integer(src));
      end;
    end;
  end;

  function ParseArray(var src: PChar; var jo: TJSON): Integer;
  var
    value: TJSON;
  begin
    if src^ <> '[' then
      Exit(-Integer(src));

    Inc(src);
    trimLeftP(src);
    if src^ = ']' then  //An empty json array
      Exit(Integer(src));

    while True do
    begin
      if (src^ = ',') or (src^ = ';') then
      begin
        Inc(src);
        jo.Add(NULL);
      end else
      begin
        value.New;
        Result:= ParseJSON(src, value);
        jo.Add(value);
        if Result < 0 then
          Exit;
      end;

      trimLeftP(src);
      case src^ of
        ';', ',':
        begin
          Inc(src);
          trimLeftP(src);
          if src^ = ']' then
          begin
            Inc(src);
            Exit(Integer(src));
          end;
        end;
        ']':
        begin
          Inc(src);
          Exit(Integer(src));
        end
      else
        Exit(-Integer(src));
      end;
    end;
  end;

begin
  if src = nil then Exit(Integer(src));

  trimLeftP(src);
  case src^ of
    #0:
      Exit(Integer(src));
    '"', '''':
    begin
      value.AsString:= ParseString(src);
      Exit(Integer(src));
    end;
    '0'..'9', '+', '-', '.':
    begin
      Result:= ParseNumber(src, value);
      if Result >= 0 then
        Exit;
    end;
    '{':
    begin
      value.CreateAsObject;
      Result:= ParseObject(src, value);
      Exit;
    end;
    '[':
    begin
      value.CreateAsArray;
      Result:= ParseArray(src, value);
      Exit;
    end;
    'T', 't':
    begin
      if Char(Word(src[1]) and $FFDF) = 'R' then
        if Char(Word(src[2]) and $FFDF) = 'U' then
          if Char(Word(src[3]) and $FFDF) = 'E' then
          begin
            case src[4] of
              #0..' ', ',', ';', '}', ']', '/':
              begin
                Inc(src, 4);
                value.AsBoolean:= True;
                Exit(Integer(src));
              end;
            end;
          end;
    end;
    'F', 'f':
    begin
      if Char(Word(src[1]) and $FFDF) = 'A' then
        if Char(Word(src[2]) and $FFDF) = 'L' then
          if Char(Word(src[3]) and $FFDF) = 'S' then
            if Char(Word(src[4]) and $FFDF) = 'E' then
            begin
              case src[5] of
                #0..' ', ',', ';', '}', ']', '/':
                begin
                  Inc(src, 5);
                  value.AsBoolean:= False;
                  Exit(Integer(src));
                end;
              end;
            end;
    end;
    'N', 'n':
    begin
      if Char(Word(src[1]) and $FFDF) = 'U' then
        if Char(Word(src[2]) and $FFDF) = 'L' then
          if Char(Word(src[3]) and $FFDF) = 'L' then
          begin
            case src[4] of
              #0..' ', ',', ';', '}', ']', '/':
              begin
                Inc(src, 4);
                value.AsNull;
                Exit(Integer(src));
              end;
            end;
          end;
    end;
  end;

  trimLeftP(src);
  value.AsString:= ParseString(src);
  Exit(Integer(src));
end;

function TJSON.GetEnumerator: TJSONEnumerator;
begin
  Result := TJSONEnumerator.Create(Self);
end;

procedure TJSON.Add(const value: TJSON);
begin
  SetAsArray(Count, value);
end;

procedure TJSON.Add(const name: string; const value: TJSON);
begin
  SetAsObject(name, value);
end;

procedure TJSON.Delete(index: Integer);
var
  jo: PJSON;
begin
  case FJSONType of
    jtJsonPtr:
      FJSONValue.jv_json^.Delete(index);
    jtArray:
    begin
      with TList<PJSON>(FJSONValue.jv_array) do
      begin
        jo:= Items[index];
        jo.Clear;
        FreeMem(jo);
        Delete(index);
      end;
    end;
  end;
end;

procedure TJSON.Delete(const name: string);
var
  I: Integer;
  pair: TPair<string, PJSON>;
begin
  case FJSONType of
    jtJsonPtr:
      FJSONValue.jv_json^.Delete(name);
    jtObject:
      begin
        pair := TDictionary<string, PJSON>(FJSONValue.jv_objectdic).ExtractPair(name);
        with TList<TPair<string, PJSON>>(FJSONValue.jv_object) do
        for I := Count - 1 downto 0 do
//          if SameStr(Items[I].Name, name) then
          if Items[I].Value = pair.Value then  //Find by Value is faster.
          begin
            Delete(I);
            Break;
          end;
        Finalize(pair.Key);
        pair.Value.Clear;
        FreeMem(pair.Value);
      end;
  end;
end;

function TJSON.Extract(index: Integer): TJSON;
var
  jo: PJSON;
begin
  Result.New;
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.Extract(index);
    jtArray:
      begin
        with TList<PJSON>(FJSONValue.jv_array) do
        begin
          jo := Items[index];
          Delete(index);
          if jo <> nil then
          begin
            Result:= jo^;
            FreeMem(jo);
          end;
        end;
      end;
  end;
end;

function TJSON.Extract(const name: string): TJSON;
var
  I: Integer;
  pair: TPair<string, PJSON>;
  jo: PJSON;
begin
  Result.New;
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.Extract(name);
    jtObject:
      begin
        pair := TDictionary<string, PJSON>(FJSONValue.jv_objectdic).ExtractPair(name);
        jo := pair.Value;
        Result := jo^;
        with TList<TPair<string, PJSON>>(FJSONValue.jv_object) do
          for I := Count - 1 downto 0 do
//            if SameStr(Items[I].Name, name) then
            if Items[I].Value = pair.Value then  //Find by Value is faster.
            begin
              Delete(I);
              Break;
            end;
        FreeMem(jo);
      end;
  end;
end;

function TJSON.Clone: TJSON;
var
  I: Integer;
  pair: TPair<string, PJSON>;
begin
  Result.New;
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.Clone;
    jtString:
      Result.AsString := string(FJSONValue.jv_string);
    jtArray:
    begin
      with TList<PJSON>(FJSONValue.jv_array) do
      for I := 0 to Count - 1 do
      begin
        Result.Add(Items[I].Clone);
      end;
    end;
    jtObject:
    begin
      with TList<TPair<string, PJSON>>(FJSONValue.jv_object) do
      for I := 0 to Count - 1 do
      begin
        pair:= Items[I];
        Result.Add(pair.Key, pair.Value.Clone);
      end;
    end;
  else
    Result := Self;
  end;
end;

function TJSON.Contains(index: Integer; value: PJSON = nil): Boolean;
var
  jo: PJSON;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.Contains(index, value);
    jtArray:
    begin
      with TList<PJSON>(FJSONValue.jv_array) do
      if (index >= 0) and (index < Count) then
      begin
        jo:= Items[index];
        Result:= jo <> nil;
        if Result and (value <> nil) then
        begin
          value.FJSONType := jtJsonPtr;
          value.FJSONValue.jv_json := jo;
        end;
      end else
        Result:= False;
    end;
  else
    Result:= False;
  end;
end;

function TJSON.Contains(const name: string; value: PJSON = nil): Boolean;
var
  jo: PJSON;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.Contains(name, value);
    jtObject:
      begin
        Result:= TDictionary<string, PJSON>(FJSONValue.jv_objectdic).TryGetValue(name, jo);
        if Result and (value <> nil) then
        begin
          value.FJSONType := jtJsonPtr;
          value.FJSONValue.jv_json := jo;
        end;
      end;
  else
    Result:= False;
  end;
end;

function TJSON.ContainsPath(const path: string; value: PJSON = nil): Boolean;
var
  pCurr: PChar;
  pStart: PChar;
  len: Integer;
  name: string;
  index: Integer;
  jo: TJSON;
begin
  pStart:= PChar(path);
  pCurr:= pStart;
  jo:= Self;
  while True do
  begin
    case pCurr^ of
      #0, '.', '[', ']':
      begin
        len:= pCurr - pStart;
        if len > 0 then
        begin
          SetLength(name, len);
          Move(pStart^, PChar(name)^, len * SizeOf(Char));
          if pCurr^ = ']' then
          begin
            index:= StrToInt(name);
            if not jo.Contains(index, @jo) then
              Exit(False);
          end else
          begin
            if not jo.Contains(name, @jo) then
              Exit(False);
          end;
        end;
        if pCurr^ = #0 then Break;
        Inc(pCurr);
        pStart:= pCurr;
      end;
    else
      Inc(pCurr);
    end;
  end;
  Result:= True;
  if value <> nil then
    value^:= jo;
end;


procedure TJSON.CreateAsArray;
begin
  FJSONType := jtArray;
  TList<PJSON>(FJSONValue.jv_array) := TList<PJSON>.Create;
end;

procedure TJSON.CreateAsObject;
begin
  FJSONType := jtObject;
  TDictionary<string, PJSON>(FJSONValue.jv_objectdic) := TDictionary<string, PJSON>.Create;
  TList<TPair<string, PJSON>>(FJSONValue.jv_object) := TList<TPair<string, PJSON>>.Create;
end;

function TJSON.GetCount: Integer;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetCount;
    jtArray:
      Result := TList<PJSON>(FJSONValue.jv_array).Count;
    jtObject:
      Result := TList<TPair<string, PJSON>>(FJSONValue.jv_object).Count;
  else
    Result := 0;
  end;
end;

function TJSON.GetJSONPtr: PJSON;
begin
  if FJSONType = jtJsonPtr then
    Result:= FJSONValue.jv_json
  else
    Result:= @Self;
//  Result := @Self;
//  while Result.FJSONType = jtJsonPtr do
//    Result := Result.FJSONValue.jv_json;
end;

function TJSON.GetJSONType: TJSONType;
begin
  if FJSONType = jtJsonPtr then
    Result := FJSONValue.jv_json^.GetJSONType
  else
    Result := FJSONType;
end;

function TJSON.GetJSONByPath(src: PChar): PJSON;
var
  s: string;
  p: PChar;
  len: Integer;
begin
  p:= src;
  Result:= JSONPtr;
  while True do
  begin
    case p^ of
      #0, '.', '[', ']':
      begin
        len:= p - src;
        if len > 0 then
        begin
          SetLength(s, len);
          Move(src^, PChar(s)^, len * SizeOf(Char));
          if p^ = ']' then
            Result:= Result^[StrToInt(s)].JSONPtr
          else
            Result:= Result^[s].JSONPtr;
        end;
        if p^ = #0 then Break;
        Inc(p);
        src:= p;
      end;
    else
      Inc(p);
    end;
  end;
end;

function TJSON.GetAsBoolean: Boolean;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetAsBoolean;
    jtBoolean:
      Result := FJSONValue.jv_boolean;
    jtInteger:
      Result := FJSONValue.jv_integer <> 0;
    jtFloat:
      Result := FJSONValue.jv_float <> 0;
    jtCurrency:
      Result := FJSONValue.jv_currency <> 0;
    jtString:
      Result := FJSONValue.jv_string <> nil;
    jtArray:
      Result := True;
    jtObject:
      Result := True;
  else
    Result := False;
  end;
end;

function TJSON.GetAsInteger: Int64;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetAsInteger;
    jtBoolean:
      Result := Ord(FJSONValue.jv_boolean);
    jtInteger:
      Result := FJSONValue.jv_integer;
    jtFloat:
      Result := Round(FJSONValue.jv_float);
    jtCurrency:
      Result := Round(FJSONValue.jv_currency);
    jtString:
      Result := StrToInt64Def(string(FJSONValue.jv_string), 0);
    jtArray:
      Result := 0;
    jtObject:
      Result := 0;
  else
    Result := 0;
  end;
end;

function TJSON.GetAsFloat: Double;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetAsFloat;
    jtBoolean:
      Result := ord(FJSONValue.jv_boolean);
    jtInteger:
      Result := FJSONValue.jv_integer;
    jtFloat:
      Result := FJSONValue.jv_float;
    jtCurrency:
      Result := FJSONValue.jv_currency;
    jtString:
      Result := StrToFloatDef(string(FJSONValue.jv_string), 0);
    jtArray:
      Result := 0;
    jtObject:
      Result := 0;
  else
    Result := 0;
  end;
end;

function TJSON.GetAsCurrency: Currency;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetAsCurrency;
    jtBoolean:
      Result := ord(FJSONValue.jv_boolean);
    jtInteger:
      Result := FJSONValue.jv_integer;
    jtFloat:
      Result := FJSONValue.jv_float;
    jtCurrency:
      Result := FJSONValue.jv_currency;
    jtString:
      Result := StrToCurr(string(FJSONValue.jv_string));
    jtArray:
      Result := 0;
    jtObject:
      Result := 0;
  else
    Result := 0;
  end;
end;

function TJSON.GetAsString: string;
begin
  case FJSONType of
    jtJsonPtr:
      Result := FJSONValue.jv_json^.GetAsString;
    // jtNull:
    // Result:= SJSONNull;
    jtBoolean:
      Result := SJSONBool[FJSONValue.jv_boolean];
    jtInteger:
      Result := IntToStr(FJSONValue.jv_integer);
    jtFloat:
      Result := FloatToStr(FJSONValue.jv_float);
    jtCurrency:
      Result := CurrToStr(FJSONValue.jv_currency);
    jtString:
      Result := string(FJSONValue.jv_string);
    // jtArray: Result:= 0;
    // jtObject: Result:= 0;
  else
    Result := '';
  end;
end;

function TJSON.GetAsJSON: string;
begin
  Result := AsJsonIndent('');
end;

function TJSON.GetAsArray(index: Integer): TJSON;
var
  jo: PJSON;
begin
  if FJSONType = jtJsonPtr then
  begin
    Result := FJSONValue.jv_json^.GetAsArray(index);
    Exit;
  end;

  if FJSONType <> jtArray then
  begin
    Clear;
    CreateAsArray;
  end;

  with TList<PJSON>(FJSONValue.jv_array) do
  begin
    if index >= Count then
    begin
      Count := index + 1;
    end;
    jo := Items[index];
    if jo = nil then
    begin
      jo := AllocMem(SizeOf(TJSON));
      Items[index] := jo;
    end;
  end;
  Result.FJSONType := jtJsonPtr;
  Result.FJSONValue.jv_json := jo;
end;

function TJSON.GetAsObject(const name: string): TJSON;
var
  jo: PJSON;
begin
  if FJSONType = jtJsonPtr then
  begin
    Result := FJSONValue.jv_json^.GetAsObject(name);
    Exit;
  end;

  if FJSONType <> jtObject then
  begin
    Clear;
    CreateAsObject;
  end;

  if not TDictionary<string, PJSON>(FJSONValue.jv_objectdic).TryGetValue(name, jo) then
  begin
    jo := AllocMem(SizeOf(TJSON));
    TList<TPair<string, PJSON>>(FJSONValue.jv_object).Add(TPair<string, PJSON>.Create(name, jo));
    TDictionary<string, PJSON>(FJSONValue.jv_objectdic).Add(name, jo);
  end;
  Result.FJSONType := jtJsonPtr;
  Result.FJSONValue.jv_json := jo;
end;

function TJSON.GetAsPath(const aPath: string): TJSON;
begin //aPath: store.book[0].title
  Result.FJSONType := jtJsonPtr;
  Result.FJSONValue.jv_json := GetJSONByPath(PChar(aPath));
end;

function TJSON.GetPair(Index: Integer): TJSONPair;
begin
  with TList<TPair<string, PJSON>>(FJSONValue.jv_object).Items[Index] do
  begin
    Result.Name := Key;
    Result.Value := value^;
  end;
end;

procedure TJSON.SetAsBoolean(const value: Boolean);
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsBoolean(value);
    Exit;
  end;

  if FJSONType <> jtBoolean then
  begin
    Clear;
    FJSONType := jtBoolean;
  end;

  FJSONValue.jv_boolean := value;
end;

procedure TJSON.SetAsInteger(const value: Int64);
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsInteger(value);
    Exit;
  end;

  if FJSONType <> jtInteger then
  begin
    Clear;
    FJSONType := jtInteger;
  end;

  FJSONValue.jv_integer := value;
end;

procedure TJSON.SetAsJSON(const value: string);
var
  src: PChar;
begin
  Clear;
  src:= PChar(value);
  ParseJSON(src, Self);
end;

procedure TJSON.SetAsFloat(const value: Double);
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsFloat(value);
    Exit;
  end;

  if FJSONType <> jtFloat then
  begin
    Clear;
    FJSONType := jtFloat;
  end;

  FJSONValue.jv_float := value;
end;

procedure TJSON.SetAsCurrency(const value: Currency);
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsCurrency(value);
    Exit;
  end;

  if FJSONType <> jtCurrency then
  begin
    Clear;
    FJSONType := jtCurrency;
  end;

  FJSONValue.jv_currency := value;
end;

procedure TJSON.SetAsString(const value: string);
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsString(value);
    Exit;
  end;

  if FJSONType <> jtString then
  begin
    Clear;
    FJSONType := jtString;
    FJSONValue.jv_string := nil;
  end;

  string(FJSONValue.jv_string) := value;
end;

procedure TJSON.SetAsArray(Idx: Integer; const value: TJSON);
var
  jo: PJSON;
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsArray(Idx, value);
    Exit;
  end;

  if FJSONType <> jtArray then
  begin
    Clear;
    CreateAsArray;
  end;

  with TList<PJSON>(FJSONValue.jv_array) do
  begin
    if Idx >= Count then
    begin
      Count := Idx + 1;
    end;
    jo := Items[Idx];
    if jo = nil then
    begin
      GetMem(jo, SizeOf(TJSON));
      Items[Idx] := jo;
    end else
      jo.Clear;
  end;

  if value.FJSONType = jtJsonPtr then
    jo^ := value.JSONPtr^
  else
    jo^ := value;
end;

procedure TJSON.SetAsObject(const name: string; const value: TJSON);
var
  jo: PJSON;
begin
  if FJSONType = jtJsonPtr then
  begin
    FJSONValue.jv_json^.SetAsObject(name, value);
    Exit;
  end;

  if FJSONType <> jtObject then
  begin
    Clear;
    CreateAsObject;
  end;

  if not TDictionary<string, PJSON>(FJSONValue.jv_objectdic).TryGetValue(name, jo) then
  begin
    GetMem(jo, SizeOf(TJSON));
    TList<TPair<string, PJSON>>(FJSONValue.jv_object).Add(TPair<string, PJSON>.Create(name, jo));
    TDictionary<string, PJSON>(FJSONValue.jv_objectdic).Add(name, jo);
  end else
    jo.Clear;

  if value.FJSONType = jtJsonPtr then
    jo^ := value.JSONPtr^
  else
    jo^ := value;
end;

procedure TJSON.SetAsPath(const aPath: string; const value: TJSON);
var
  jo: PJSON;
begin
  jo:= GetJSONByPath(PChar(aPath));
  jo.Clear;
  jo^:= value;
end;

procedure TJSON.AsNull;
begin
  Clear;
end;

class operator TJSON.Implicit(const value: Boolean): TJSON;
begin
  Result.FJSONType := jtBoolean;
  Result.FJSONValue.jv_boolean := value;
end;

class operator TJSON.Implicit(const value: Integer): TJSON;
begin
  Result.FJSONType := jtInteger;
  Result.FJSONValue.jv_integer := value;
end;

class operator TJSON.Implicit(const value: Cardinal): TJSON;
begin
  Result.FJSONType := jtInteger;
  Result.FJSONValue.jv_integer := value;
end;

class operator TJSON.Implicit(const value: Int64): TJSON;
begin
  Result.FJSONType := jtInteger;
  Result.FJSONValue.jv_integer := value;
end;

class operator TJSON.Implicit(const value: Single): TJSON;
begin
  Result.FJSONType := jtFloat;
  Result.FJSONValue.jv_float := value;
end;

class operator TJSON.Implicit(const value: Double): TJSON;
begin
  Result.FJSONType := jtFloat;
  Result.FJSONValue.jv_float := value;
end;

class operator TJSON.Implicit(const value: Extended): TJSON;
begin
  Result.FJSONType := jtFloat;
  Result.FJSONValue.jv_float := value;
end;

class operator TJSON.Implicit(const value: Currency): TJSON;
begin
  Result.FJSONType := jtCurrency;
  Result.FJSONValue.jv_currency := value;
end;

//class operator TJSON.Implicit(const Value: AnsiString): TJSON;
//begin
//  Result.FJSONType := jtString;
//  Result.FJSONValue.jv_string := nil;
//  WideString(Result.FJSONValue.jv_string) := WideString(Value);
//end;

class operator TJSON.Implicit(const value: string): TJSON;
begin
  Result.FJSONType := jtString;
  Result.FJSONValue.jv_string := nil;
  string(Result.FJSONValue.jv_string) := value;
end;

class operator TJSON.Implicit(const value: Variant): TJSON;
begin
  case VarType(value) of
    varEmpty, varNull:
      begin
        Result.New;
      end;

    varBoolean:
      begin
        Result.FJSONType := jtBoolean;
        Result.FJSONValue.jv_boolean := value;
      end;

    varSmallInt, varInteger, varShortInt, varByte, varWord, varLongWord, varInt64, varUInt64:
      begin
        Result.FJSONType := jtInteger;
        Result.FJSONValue.jv_integer := value;
      end;

    varSingle, varDouble, varDate:
      begin
        Result.FJSONType := jtFloat;
        Result.FJSONValue.jv_float := value;
      end;

    varCurrency:
      begin
        Result.FJSONType := jtCurrency;
        Result.FJSONValue.jv_currency := value;
      end;

    varString, varUString, varOleStr:
      begin
        Result.FJSONType := jtString;
        Result.FJSONValue.jv_string := nil;
        string(Result.FJSONValue.jv_string) := value;
      end;
  else
    Result.New;
  end;
end;

class operator TJSON.Implicit(const value: TJSON): Boolean;
begin
  Result := value.AsBoolean;
end;

class operator TJSON.Implicit(const value: TJSON): Integer;
begin
  Result := value.AsInteger;
end;

class operator TJSON.Implicit(const value: TJSON): Cardinal;
begin
  Result := value.AsInteger;
end;

class operator TJSON.Implicit(const value: TJSON): Int64;
begin
  Result := value.AsInteger;
end;

class operator TJSON.Implicit(const value: TJSON): Single;
begin
  Result := value.AsFloat;
end;

class operator TJSON.Implicit(const value: TJSON): Double;
begin
  Result := value.AsFloat;
end;

class operator TJSON.Implicit(const value: TJSON): Extended;
begin
  Result := value.AsFloat;
end;

class operator TJSON.Implicit(const value: TJSON): Currency;
begin
  Result := value.AsCurrency;
end;

class operator TJSON.Implicit(const value: TJSON): string;
begin
  Result := value.AsString;
end;

// class operator TJSON.Implicit(const value: TJSON): Variant;
// begin
// case value.JSONType of
// jtJSON:
// Result:= value.JSONValue.jv_json^;
// jtBoolean:
// Result:= value.JSONValue.jv_boolean;
// jtInteger:
// Result:= value.JSONValue.jv_integer;
// jtFloat:
// Result:= value.JSONValue.jv_float;
// jtCurrency:
// Result:= value.JSONValue.jv_Currency;
// jtString:
// Result:= WideString(value.JSONValue.jv_string);
// else
// Result:= Variants.NULL;
// end;
// end;

class operator TJSON.Equal(const a, b: TJSON): Boolean;
  function SameJson(jo1, jo2: PJSON): Boolean;
  var
    index: Integer;
    listArr1: TList<PJSON>;
    listArr2: TList<PJSON>;
    listObj1: TList<TPair<string, PJSON>>;
    listObj2: TList<TPair<string, PJSON>>;
    pair1: TPair<string, PJSON>;
    pair2: TPair<string, PJSON>;
  begin
    if jo1 = jo2 then Exit(True);
    Result := jo1.JSONType = jo2.JSONType;
    if Result then
      case jo1.JSONType of
        // jtJsonPtr: ;
        jtNull:
           Result := True;
        jtBoolean:
          Result := jo1.FJSONValue.jv_boolean = jo2.FJSONValue.jv_boolean;
        jtInteger:
          Result := jo1.FJSONValue.jv_integer = jo2.FJSONValue.jv_integer;
        jtFloat:
          Result := jo1.FJSONValue.jv_float = jo2.FJSONValue.jv_float;
        jtCurrency:
          Result := jo1.FJSONValue.jv_currency = jo2.FJSONValue.jv_currency;
        jtString:
          Result := string(jo1.FJSONValue.jv_string) = string(jo2.FJSONValue.jv_string);
         jtArray:
         begin
           listArr1:= TList<PJSON>(jo1.FJSONValue.jv_array);
           listArr2:= TList<PJSON>(jo2.FJSONValue.jv_array);
           if listArr1.Count <> listArr2.Count then
             Exit(False);
           for index := 0 to listArr1.Count - 1 do
             if not SameJson(listArr1[index], listArr2[index]) then
               Exit(False);
           Result:= True;
         end;
         jtObject:
         begin
           listObj1:= TList<TPair<string, PJSON>>(jo1.FJSONValue.jv_object);
           listObj2:= TList<TPair<string, PJSON>>(jo2.FJSONValue.jv_object);
           if listObj1.Count <> listObj2.Count then
             Exit(False);
           for index := 0 to listObj1.Count - 1 do
           begin
              pair1:= listObj1[index];
              pair2:= listObj2[index];
             if not (pair1.Key = pair2.Key) then
               Exit(False);
             if not SameJson(pair1.Value, pair2.Value) then
               Exit(False);
           end;
           Result:= True;
          end;
      end;
  end;
begin
  Result:= SameJson(@a, @b);
end;

class operator TJSON.NotEqual(const a, b: TJSON): Boolean;
begin
  Result := not(a = b);
end;

class operator TJSON.Add(const a: TJSON; b: Char): string;
begin
  Result := a.AsString + b;
end;

class operator TJSON.Add(const a: Char; const b: TJSON): string;
begin
  Result := a + b.AsString;
end;

end.

