unit ssjsonReflect;

interface

uses
  SysUtils,
  Classes,
  Rtti,
  TypInfo,
  DateUtils,
  Generics.Collections,
  ssjson;

type
//  EConversionError = class(Exception);

  TJSONMarshal = class;
  TJSONUnmarshal = class;

  TJsonConverter = reference to function(ctx: TJSONMarshal; var jo: TJSON; const value: TValue): Boolean;
  TJsonReverter = reference to function(ctx: TJSONUnmarshal; const jo: TJSON; var Value: TValue): Boolean;

  TJSONMarshal = class
  private
    FContext: TRttiContext;
    FConverters: TDictionary<PTypeInfo, TJsonConverter>;
    function IsList(aType: PTypeInfo): Boolean;
    function ToInteger(value: TValue): TJSON;
    function ToInt64(value: TValue): TJSON;
    function ToFloat(field: TRttiField; value: TValue): TJSON;
    function ToChar(value: TValue): TJSON;
    function ToWideChar(value: TValue): TJSON;
    function ToStr(value: TValue): TJSON;
    function ToRecord(value: TValue): TJSON;
    function ToClass(value: TValue): TJSON;
    function ToDynArray(field: TRttiField; value: TValue): TJSON;
    function ToJSON(field: TRttiField; const value: TValue): TJSON; overload;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterConverter(clazz: TClass; func: TJsonConverter); overload;
    procedure RegisterConverter(clazz: PTypeInfo; func: TJsonConverter); overload;
    function Marshal<T>(const Data: T): TJSON;
  end;

  TJSONUnmarshal = class
  private
    FContext: TRttiContext;

    function CreateInstance(aType: PTypeInfo): TValue;
    function IsList(aType: PTypeInfo): Boolean;
    function IsParameterizedType(aType: PTypeInfo): Boolean;
    function GetParameterizedType(aType: PTypeInfo): TRttiType;
    function GetFieldDefault(rttiField: TRttiField; const jo: TJSON; var isNewValue: Boolean): TJSON;

    function FromJson(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean; overload;

    function FromInt(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromInt64(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromFloat(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromChar(const jo: TJSON; var value: TValue): Boolean;
    function FromWideChar(const jo: TJSON; var value: TValue): Boolean;
    function FromString(const jo: TJSON; var value: TValue): Boolean;
    function FromClass(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromRecord(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromList(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromSet(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
    function FromArray(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
  public
    FReverters: TDictionary<PTypeInfo, TJsonReverter>;
    constructor Create;
    destructor Destroy; override;

    procedure RegisterReverter(aClass: TClass; func: TJsonReverter); overload;
    procedure RegisterReverter(aType: PTypeInfo; func: TJsonReverter); overload;
    function Unmarshal<T>(const jo: TJSON): T; overload;
    function Unmarshal<T>(const jo: TJSON; var obj: T): Boolean; overload;
  end;

  TJsonAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  JsonName = class(TJsonAttribute);
  JsonDefault = class(TJsonAttribute);
  JsonISO8601 = class(TCustomAttribute);

  TRttiFieldHelper = class helper for TRttiField
  public
    function GetFieldName: string;
    function FormatUsingISO8601: Boolean;
  end;

  TJSONHelper = record helper for TJSON
  public
    class function Marshal<T>(const data: T; mar: TJSONMarshal = nil): TJSON; overload; static;
    class function MarshalIndent<T>(const data: T; const Indent: string = '  '; mar: TJSONMarshal = nil): string; overload; static;
    class function Unmarshal<T>(var data: T; const json: TJSON; unmar: TJSONUnmarshal = nil): Boolean; overload; static;
    class function Unmarshal<T>(var data: T; const json: string; unmar: TJSONUnmarshal = nil): Boolean; overload; static;
    class function Unmarshal<T>(const json: TJSON; unmar: TJSONUnmarshal = nil): T; overload; static;
    class function Unmarshal<T>(const json: string; unmar: TJSONUnmarshal = nil): T; overload; static;
  end;

  TJSONObjectHelper = class helper for TObject
  public
    function Marshal(mar: TJSONMarshal = nil): TJSON;
    function MarshalIndent(mar: TJSONMarshal = nil; const Indent: string = '  '): string;
    constructor Unmarshal(const jsonObj: TJSON; unmar: TJSONUnmarshal = nil); overload;
    constructor Unmarshal(const jsonText: string; unmar: TJSONUnmarshal = nil); overload;
  end;

  function JavaToDelphiDateTime(const dt: Int64): TDateTime;
  function DelphiToJavaDateTime(const dt: TDateTime): Int64;
  function ISO8601DateToJavaDateTime(const str: String; var ms: Int64): Boolean;
  function ISO8601DateToDelphiDateTime(const str: string; var dt: TDateTime): Boolean;
  function DelphiDateTimeToISO8601Date(dt: TDateTime): string;

implementation


function JavaToDelphiDateTime(const dt: Int64): TDateTime;
var
  univTime: TDateTime;
begin
  univTime := UnixDateDelta + (dt / 86400000);

  if DateOf(univTime) = 0 then
    Exit(0);

  Result := TTimeZone.Local.ToLocalTime(univTime);
end;

function DelphiToJavaDateTime(const dt: TDateTime): Int64;
var
  univTime: TDateTime;
begin
  univTime := TTimeZone.Local.ToUniversalTime(dt);

  Result := Round((univTime - UnixDateDelta) * 86400000);
end;

function ISO8601DateToJavaDateTime(const str: string; var ms: Int64): Boolean;
type
  TState = (
    stStart, stYear, stMonth, stWeek, stWeekDay, stDay, stDayOfYear,
    stHour, stMin, stSec, stMs, stUTC, stGMTH, stGMTM,
    stGMTend, stEnd);

  TPerhaps = (yes, no, perhaps);
  TDateTimeInfo = record
    year: Word;
    month: Word;
    week: Word;
    weekday: Word;
    day: Word;
    dayofyear: Integer;
    hour: Word;
    minute: Word;
    second: Word;
    ms: Word;
    bias: Integer;
  end;

{$if (sizeof(Char) = 1)}
  PSOChar = PWideChar;
  SOChar = WideChar;
{$else}
  SOChar = Char;
  PSOChar = PChar;
{$ifend}

var
  p: PSOChar;
  state: TState;
  pos, v: Word;
  sep: TPerhaps;
  inctz, havetz, havedate: Boolean;
  st: TDateTimeInfo;
  DayTable: PDayTable;

  function get(var v: Word; c: SOChar): Boolean; {$IFDEF HAVE_INLINE} inline;{$ENDIF}
  begin
    case c of
      '0'..'9':
      begin
        Result := True;
        v := v * 10 + Ord(c) - Ord('0');
      end;
    else
      Result:= False;
    end;
  end;

label
  error;
begin
  p := PSOChar(str);
  sep := perhaps;
  state := stStart;
  pos := 0;
  FillChar(st, SizeOf(st), 0);
  havedate := True;
  inctz := False;
  havetz := False;

  while true do
  case state of
    stStart:
      case p^ of
        '0'..'9': state := stYear;
        'T', 't':
          begin
            state := stHour;
            pos := 0;
            inc(p);
            havedate := False;
          end;
      else
        goto error;
      end;
    stYear:
      case pos of
        0..1,3:
              if get(st.year, p^) then
              begin
                Inc(pos);
                Inc(p);
              end else
                goto error;
        2:    case p^ of
                '0'..'9':
                  begin
                    st.year := st.year * 10 + ord(p^) - ord('0');
                    Inc(pos);
                    Inc(p);
                  end;
                ':':
                  begin
                    havedate := false;
                    st.hour := st.year;
                    st.year := 0;
                    inc(p);
                    pos := 0;
                    state := stMin;
                    sep := yes;
                  end;
              else
                goto error;
              end;
        4: case p^ of
             '-': begin
                    pos := 0;
                    Inc(p);
                    sep := yes;
                    state := stMonth;
                  end;
             '0'..'9':
                  begin
                    sep := no;
                    pos := 0;
                    state := stMonth;
                  end;
             'W', 'w' :
                  begin
                    pos := 0;
                    Inc(p);
                    state := stWeek;
                  end;
             'T', 't', ' ':
                  begin
                    state := stHour;
                    pos := 0;
                    inc(p);
                    st.month := 1;
                    st.day := 1;
                  end;
             #0:
                  begin
                    st.month := 1;
                    st.day := 1;
                    state := stEnd;
                  end;
           else
             goto error;
           end;
      end;
    stMonth:
      case pos of
        0:  case p^ of
              '0'..'9':
                begin
                  st.month := ord(p^) - ord('0');
                  Inc(pos);
                  Inc(p);
                end;
              'W', 'w':
                begin
                  pos := 0;
                  Inc(p);
                  state := stWeek;
                end;
            else
              goto error;
            end;
        1:  if get(st.month, p^) then
            begin
              Inc(pos);
              Inc(p);
            end else
              goto error;
        2: case p^ of
             '-':
                  if (sep in [yes, perhaps])  then
                  begin
                    pos := 0;
                    Inc(p);
                    state := stDay;
                    sep := yes;
                  end else
                    goto error;
             '0'..'9':
                  if sep in [no, perhaps] then
                  begin
                    pos := 0;
                    state := stDay;
                    sep := no;
                  end else
                  begin
                    st.dayofyear := st.month * 10 + Ord(p^) - Ord('0');
                    st.month := 0;
                    inc(p);
                    pos := 3;
                    state := stDayOfYear;
                  end;
             'T', 't', ' ':
                  begin
                    state := stHour;
                    pos := 0;
                    inc(p);
                    st.day := 1;
                 end;
             #0:
               begin
                 st.day := 1;
                 state := stEnd;
               end;
           else
             goto error;
           end;
      end;
    stDay:
      case pos of
        0:  if get(st.day, p^) then
            begin
              Inc(pos);
              Inc(p);
            end else
              goto error;
        1:  if get(st.day, p^) then
            begin
              Inc(pos);
              Inc(p);
            end else
            if sep in [no, perhaps] then
            begin
              st.dayofyear := st.month * 10 + st.day;
              st.day := 0;
              st.month := 0;
              state := stDayOfYear;
            end else
              goto error;

        2: case p^ of
             'T', 't', ' ':
                  begin
                    pos := 0;
                    Inc(p);
                    state := stHour;
                  end;
             #0:  state := stEnd;
           else
             goto error;
           end;
      end;
    stDayOfYear:
      begin
        if (st.dayofyear <= 0) then goto error;
        case p^ of
          'T', 't', ' ':
               begin
                 pos := 0;
                 Inc(p);
                 state := stHour;
               end;
          #0:  state := stEnd;
        else
          goto error;
        end;
      end;
    stWeek:
      begin
        case pos of
          0..1: if get(st.week, p^) then
                begin
                  inc(pos);
                  inc(p);
                end else
                  goto error;
          2: case p^ of
               '-': if (sep in [yes, perhaps]) then
                    begin
                      Inc(p);
                      state := stWeekDay;
                      sep := yes;
                    end else
                      goto error;
               '1'..'7':
                    if sep in [no, perhaps] then
                    begin
                      state := stWeekDay;
                      sep := no;
                    end else
                      goto error;
             else
               goto error;
             end;
        end;
      end;
    stWeekDay:
      begin
        if (st.week > 0) and get(st.weekday, p^) then
        begin
          inc(p);
          v := st.year - 1;
          v := ((v * 365) + (v div 4) - (v div 100) + (v div 400)) mod 7 + 1;
          st.dayofyear := (st.weekday - v) + ((st.week) * 7) + 1;
          if v <= 4 then dec(st.dayofyear, 7);
          case p^ of
            'T', 't', ' ':
                 begin
                   pos := 0;
                   Inc(p);
                   state := stHour;
                 end;
            #0:  state := stEnd;
          else
            goto error;
          end;
        end else
          goto error;
      end;
    stHour:
      case pos of
        0:    case p^ of
                '0'..'9':
                    if get(st.hour, p^) then
                    begin
                      inc(pos);
                      inc(p);
                      end else
                        goto error;
                '-':
                  begin
                    inc(p);
                    state := stMin;
                  end;
              else
                goto error;
              end;
        1:    if get(st.hour, p^) then
              begin
                inc(pos);
                inc(p);
              end else
                goto error;
        2: case p^ of
             ':': if sep in [yes, perhaps] then
                  begin
                    sep := yes;
                    pos := 0;
                    Inc(p);
                    state := stMin;
                  end else
                    goto error;
             ',', '.':
                begin
                  Inc(p);
                  state := stMs;
                end;
             '+':
               if havedate then
               begin
                 state := stGMTH;
                 pos := 0;
                 v := 0;
                 inc(p);
               end else
                 goto error;
             '-':
               if havedate then
               begin
                 state := stGMTH;
                 pos := 0;
                 v := 0;
                 inc(p);
                 inctz := True;
               end else
                 goto error;
             'Z', 'z':
                  if havedate then
                    state := stUTC else
                    goto error;
             '0'..'9':
                  if sep in [no, perhaps] then
                  begin
                    pos := 0;
                    state := stMin;
                    sep := no;
                  end else
                    goto error;
             #0:  state := stEnd;
           else
             goto error;
           end;
      end;
    stMin:
      case pos of
        0: case p^ of
             '0'..'9':
                if get(st.minute, p^) then
                begin
                  inc(pos);
                  inc(p);
                end else
                  goto error;
             '-':
                begin
                  inc(p);
                  state := stSec;
                end;
           else
             goto error;
           end;
        1: if get(st.minute, p^) then
           begin
             inc(pos);
             inc(p);
           end else
             goto error;
        2: case p^ of
             ':': if sep in [yes, perhaps] then
                  begin
                    pos := 0;
                    Inc(p);
                    state := stSec;
                    sep := yes;
                  end else
                    goto error;
             ',', '.':
                begin
                  Inc(p);
                  state := stMs;
                end;
             '+':
               if havedate then
               begin
                 state := stGMTH;
                 pos := 0;
                 v := 0;
                 inc(p);
               end else
                 goto error;
             '-':
               if havedate then
               begin
                 state := stGMTH;
                 pos := 0;
                 v := 0;
                 inc(p);
                 inctz := True;
               end else
                 goto error;
             'Z', 'z':
                  if havedate then
                    state := stUTC else
                    goto error;
             '0'..'9':
                  if sep in [no, perhaps] then
                  begin
                    pos := 0;
                    state := stSec;
                  end else
                    goto error;
             #0:  state := stEnd;
           else
             goto error;
           end;
      end;
    stSec:
      case pos of
        0..1: if get(st.second, p^) then
              begin
                inc(pos);
                inc(p);
              end else
                goto error;
        2:    case p^ of
               ',', '.':
                  begin
                    Inc(p);
                    state := stMs;
                  end;
               '+':
                 if havedate then
                 begin
                   state := stGMTH;
                   pos := 0;
                   v := 0;
                   inc(p);
                 end else
                   goto error;
               '-':
                 if havedate then
                 begin
                   state := stGMTH;
                   pos := 0;
                   v := 0;
                   inc(p);
                   inctz := True;
                 end else
                   goto error;
               'Z', 'z':
                    if havedate then
                      state := stUTC else
                      goto error;
               #0: state := stEnd;
              else
               goto error;
              end;
      end;
    stMs:
      case p^ of
        '0'..'9':
        begin
          st.ms := st.ms * 10 + ord(p^) - ord('0');
          inc(p);
        end;
        '+':
          if havedate then
          begin
            state := stGMTH;
            pos := 0;
            v := 0;
            inc(p);
          end else
            goto error;
        '-':
          if havedate then
          begin
            state := stGMTH;
            pos := 0;
            v := 0;
            inc(p);
            inctz := True;
          end else
            goto error;
        'Z', 'z':
             if havedate then
               state := stUTC else
               goto error;
        #0: state := stEnd;
      else
        goto error;
      end;
    stUTC: // = GMT 0
      begin
        havetz := True;
        inc(p);
        if p^ = #0 then
          Break else
          goto error;
      end;
    stGMTH:
      begin
        havetz := True;
        case pos of
          0..1: if get(v, p^) then
                begin
                  inc(p);
                  inc(pos);
                end else
                  goto error;
          2:
            begin
              st.bias := v * 60;
              case p^ of
                ':': if sep in [yes, perhaps] then
                     begin
                       state := stGMTM;
                       inc(p);
                       pos := 0;
                       v := 0;
                       sep := yes;
                     end else
                       goto error;
                '0'..'9':
                     begin
                       state := stGMTM;
                       pos := 1;
                       sep := no;
                       inc(p);
                       v := ord(p^) - ord('0');
                     end;
                #0: state := stGMTend;
              else
                goto error;
              end;

            end;
        end;
      end;
    stGMTM:
      case pos of
        0..1:  if get(v, p^) then
               begin
                 inc(p);
                 inc(pos);
               end else
                 goto error;
        2:  case p^ of
              #0:
                begin
                  state := stGMTend;
                  inc(st.Bias, v);
                end;
            else
              goto error;
            end;
      end;
    stGMTend:
      begin
        if not inctz then
          st.Bias := -st.bias;
        Break;
      end;
    stEnd:
    begin

      Break;
    end;
  end;

  if (st.hour >= 24) or (st.minute >= 60) or (st.second >= 60) or (st.ms >= 1000) or (st.week > 53)
    then goto error;

  if not havetz then
    st.bias := Trunc(TTimeZone.Local.GetUTCOffset(Now).Negate.TotalMinutes);
//    st.bias := GetTimeBias;

  ms := st.ms + st.second * 1000 + (st.minute + st.bias) * 60000 + st.hour * 3600000;
  if havedate then
  begin
    DayTable := @MonthDays[IsLeapYear(st.year)];
    if st.month <> 0 then
    begin
      if not (st.month in [1..12]) or (DayTable^[st.month] < st.day) then
        goto error;

      for v := 1 to  st.month - 1 do
        Inc(ms, DayTable^[v] * 86400000);
    end;
    dec(st.year);
    ms := ms + (int64((st.year * 365) + (st.year div 4) - (st.year div 100) +
      (st.year div 400) + st.day + st.dayofyear - 719163) * 86400000);
  end;

  Result := True;
  Exit;
error:
  Result := False;
end;

function ISO8601DateToDelphiDateTime(const str: string; var dt: TDateTime): Boolean;
var
  ms: Int64;
begin
  ms := 0;
  Result := ISO8601DateToJavaDateTime(str, ms);
  if Result then
    dt := JavaToDelphiDateTime(ms)
end;

function DelphiDateTimeToISO8601Date(dt: TDateTime): String;
const
  FMT_DATE = '%.4d-%.2d-%.2d';
  FMT_TIME = 'T%.2d:%.2d:%.2d.%.3d';
  FMT_ZONE = '%s%.2d:%.2d';
var
  year, month, day, hour, min, sec, msec: Word;
  tzh: SmallInt;
  tzm: Word;
  sign: Char;
  bias: Integer;
begin
  try
    DecodeDate(dt, year, month, day);
    DecodeTime(dt, hour, min, sec, msec);
    bias := Trunc(TTimeZone.Local.GetUTCOffset(Now).Negate.TotalMinutes);
    tzh := Abs(bias) div 60;
    tzm := Abs(bias) - tzh * 60;
    if Bias > 0 then
      sign := '-' else
      sign := '+';
    Result := Format(FMT_DATE + FMT_TIME + FMT_ZONE,
      [year, month, day, hour, min, sec, msec, sign, tzh, tzm]);
  except
    if dt = 0 then
      raise
    else
      DelphiDateTimeToISO8601Date(0);
  end;
end;

{ TJSONMarshal }

constructor TJSONMarshal.Create;
begin
  FContext := TRttiContext.Create;
  FConverters := TDictionary<PTypeInfo, TJsonConverter>.Create;

  //Add a TStringList Converter
  RegisterConverter(TStringList.ClassInfo, function(ctx: TJSONMarshal; var obj: TJSON; const value: TValue): Boolean
  var
    sl: TStringList;
    i: integer;
  begin
    sl:= value.AsType<TStringList>;
    for i := 0 to sl.count - 1 do
      obj[i] := sl[i];
    Result:= True;
  end);
end;

destructor TJSONMarshal.Destroy;
begin
  FContext.Free;
  FConverters.Free;
  inherited;
end;

function TJSONMarshal.IsList(aType: PTypeInfo): Boolean;
var
  rMethod: TRttiMethod;
begin
  rMethod := FContext.GetType(aType).GetMethod('Add');

  Result := (rMethod <> nil) and
            (rMethod.MethodKind = mkFunction) and
            (Length(rMethod.GetParameters) = 1)
end;

procedure TJSONMarshal.RegisterConverter(clazz: PTypeInfo;
  func: TJsonConverter);
begin
  FConverters.Add(clazz, func);
end;

procedure TJSONMarshal.RegisterConverter(clazz: TClass; func: TJsonConverter);
begin
  FConverters.Add(clazz.ClassInfo, func);
end;

function TJSONMarshal.ToInteger(value: TValue): TJSON;
begin
  if value.TypeInfo = TypeInfo(Boolean) then
    Result:= value.AsBoolean
  else
    Result := TValueData(value).FAsSLong;
end;

function TJSONMarshal.ToInt64(value: TValue): TJSON;
begin
  Result := value.AsInt64;
end;

function TJSONMarshal.ToFloat(field: TRttiField; value: TValue): TJSON;
begin
  Result.New;
  if value.TypeInfo = TypeInfo(TDateTime) then
  begin
    if TValueData(value).FAsDouble > 0 then
    begin
      if field.FormatUsingISO8601 then
        Result := DelphiDateTimeToISO8601Date(value.AsType<TDateTime>)
      else
        Result := DelphiToJavaDateTime(value.AsType<TDateTime>);

    end;
  end
  else
  begin
    case value.TypeData.FloatType of
      ftSingle: Result := TValueData(value).FAsSingle;
      ftDouble: Result := TValueData(value).FAsDouble;
      ftExtended: Result := TValueData(value).FAsExtended;
      ftComp: Result := TValueData(value).FAsSInt64;
      ftCurr: Result := TValueData(value).FAsCurr;
    end;
  end;
end;

function TJSONMarshal.ToChar(value: TValue): TJSON;
begin
  Result := string(value.AsType<Char>);
end;

function TJSONMarshal.ToWideChar(value: TValue): TJSON;
begin
  Result := value.AsType<WideChar>;
end;

function TJSONMarshal.ToStr(value: TValue): TJSON;
begin
  Result := value.AsString;
end;

function TJSONMarshal.ToRecord(value: TValue): TJSON;
var
  field: TRttiField;
  fieldValue: TValue;
  jsonValue: TJSON;
  fieldName: string;
begin
  Result.New;

  if value.Kind = tkRecord then
  begin
    for field in FContext.GetType(value.TypeInfo).GetFields do
    begin
      if (field.FieldType <> nil) then
      begin
        fieldName:= field.GetFieldName;
        if fieldName = '-' then Continue;   // Field is ignored

        fieldValue:= field.GetValue(value.GetReferenceToRawData);
        if fieldValue.IsObject and (fieldValue.AsObject = nil) then
        begin
          Continue;
        end;

        jsonValue := ToJSON(field, fieldValue);
        if not jsonValue.IsNull then
          Result[fieldName]:= jsonValue;
      end;
    end;
  end;
end;

function TJSONMarshal.ToClass(value: TValue): TJSON;
var
  field: TRttiField;
  fieldValue: TValue;
  jsonValue: TJSON;
  fieldName: string;
  isListValue: Boolean;
begin
  Result.New;

  if value.IsObject and (value.AsObject <> nil) then
  begin
    isListValue := isList(value.TypeInfo);

    for field in FContext.GetType(value.AsObject.ClassType).GetFields do
    begin
      if (field.FieldType <> nil) (* and (f.Visibility in [mvPublic, mvPublished])*) then
      begin
        fieldName:= field.GetFieldName;
        if fieldName = '-' then Continue;   // Field is ignored
        fieldValue := field.GetValue(value.AsObject);

        if fieldValue.IsObject and (fieldValue.AsObject = nil) then
        begin
          Continue;
        end;

        if isListValue and (field.Name = 'FItems') then
        begin
          Exit(ToJSON(field, fieldValue));
        end;

        jsonValue:= ToJSON(field, fieldValue);
        if not jsonValue.IsNull then
          Result[fieldName]:= jsonValue;
      end;
    end;
  end;
end;

function TJSONMarshal.ToDynArray(field: TRttiField; value: TValue): TJSON;
var
  i: Integer;
  v: TValue;
begin
  Result.New;

  for i := 0 to value.GetArrayLength - 1 do
  begin
    v := value.GetArrayElement(i);
    if not v.IsEmpty then
    begin
      Result.Add(ToJSon(field, v));
    end;
  end;
end;

function TJSONMarshal.ToJSON(field: TRttiField; const value: TValue): TJSON;
var
  converter: TJsonConverter;
begin
  Result.New;
  if FConverters.TryGetValue(value.TypeInfo, converter)  then
  begin
    converter(Self, Result, value);
  end else
  case value.Kind of
    tkInt64: Result := ToInt64(value);
    tkChar: Result := ToChar(value);
    tkSet, tkInteger, tkEnumeration: Result := ToInteger(value);
    tkFloat: Result := ToFloat(field, value);
    tkString, tkLString, tkUString, tkWString: Result := ToStr(value);
    tkClass: Result := ToClass(value);
    tkWChar: Result := ToWideChar(value);
//    tkVariant: ToVariant;
    tkRecord: Result := ToRecord(value);
//    tkArray: ToArray;
    tkDynArray: Result := ToDynArray(field, value);
//    tkClassRef: ToClassRef;
//    tkInterface: ToInterface;
//  else
//    Result := Null;
  end;
end;

function TJSONMarshal.Marshal<T>(const Data: T): TJSON;
begin
  Result:= ToJSON(nil, TValue.From<T>(Data));
end;

{ TJSONUnmarshal }

constructor TJSONUnmarshal.Create;
begin
  FContext := TRttiContext.Create;
  FReverters := TDictionary<PTypeInfo, TJsonReverter>.Create;

  //Add a TStringList Reverter
  RegisterReverter(TypeInfo(TStringList), function(ctx: TJSONUnmarshal; const obj: TJSON; var value: TValue): Boolean
  var
    i: TJSON;
    sl: TStringList;
  begin
    sl:= value.AsType<TStringList>;
    for i in obj do
    begin
      sl.Add(i.AsString);
    end;
    value:= TValue.From<TStringList>(sl);
    Result:= True;
  end);

end;

function TJSONUnmarshal.CreateInstance(aType: PTypeInfo): TValue;
var
  rType: TRttiType;
  rMethod: TRTTIMethod;
  metaClass: TClass;
begin
  rType := FContext.GetType(aType);
  if ( rType <> nil ) then
    for rMethod in rType.GetMethods do
    begin
      if rMethod.HasExtendedInfo and rMethod.IsConstructor then
      begin
        if Length(rMethod.GetParameters) = 0 then
        begin
          // invoke
          metaClass := rType.AsInstance.MetaclassType;
          Exit(rMethod.Invoke(metaClass, []).AsObject);
        end;
      end;
    end;
  Exit(nil);
//  raise EConversionError.CreateFmt('No default constructor found for clas "%s".', [GetTypeData(aType).ClassType.ClassName]);
end;

destructor TJSONUnmarshal.Destroy;
begin
  FContext.Free;
  FReverters.Free;
  inherited;
end;

procedure TJSONUnmarshal.RegisterReverter(aType: PTypeInfo; func: TJsonReverter);
begin
  FReverters.Add(aType, func);
end;

procedure TJSONUnmarshal.RegisterReverter(aClass: TClass; func: TJsonReverter);
begin
  FReverters.Add(aClass.ClassInfo, func);
end;

function TJSONUnmarshal.FromInt(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  i: Integer;
  typeData: PTypeData;
  isValid: Boolean;
  jsonTemp: TJSON;
  rttiType: TRttiType;
begin
  Result:= False;
  case jo.JSONType of
    jtBoolean, jtInteger:
    begin
      i := jo.AsInteger;

      typeData := GetTypeData(aType);
      if typeData.MaxValue > typeData.MinValue then
        isValid := (i >= typeData.MinValue) and (i <= typeData.MaxValue)
      else
        isValid := (i >= typeData.MinValue) and (i <= Int64(PCardinal(@typeData.MaxValue)^));

      if isValid then
      begin
        TValue.Make(@i, aType, value);
        Result:= True;
      end;
    end;

   jtString:
    begin
      rttiType := FContext.GetType(aType);

      if rttiType is TRttiEnumerationType then
      begin
        if not TryStrToInt(jo.AsString, i) then
          i := Ord(GetEnumValue(aType, jo.AsString));

        TValue.Make(@i, aType, value);
        Result:= True;
      end
      else
      begin
        jsonTemp.New(jo.AsString);
        try
          if not jsonTemp.IsString then
            Result := FromInt(aType, jsonTemp, value);
       finally
          jsonTemp.Clear;
        end;
      end;
    end;
  end;
end;

function TJSONUnmarshal.FromInt64(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  i: Int64;
begin
  case jo.JSONType of
    jtInteger:
    begin
      TValue.Make(nil, aType, value);
      TValueData(value).FAsSInt64 := jo.AsInteger;
      Result:= True;
    end;
    jtString:
    if TryStrToInt64(jo.AsString, i) then
    begin
      TValue.Make(nil, aType, value);
      TValueData(value).FAsSInt64 := i;
      Result:= True;
    end else
      Result:= False;
  else
    Result:= False;
  end;
end;

function TJSONUnmarshal.FromFloat(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  jsonTemp: TJSON;
  javaDateTime: Int64;
begin
  Result:= False;
  case jo.JSONType of
    jtInteger, jtFloat, jtCurrency:
    begin
      if aType = TypeInfo(TDateTime) then
      begin
        { TODO -oZE -c : Handle DataTime  2015/12/1 12:51:25 }
        value := JavaToDelphiDateTime(jo.AsInteger);
      end
      else
      begin
        TValue.Make(nil, aType, value);

        case GetTypeData(aType).FloatType of
          ftSingle: TValueData(value).FAsSingle := jo.AsFloat;
          ftDouble: TValueData(value).FAsDouble := jo.AsFloat;
          ftExtended: TValueData(value).FAsExtended := jo.AsFloat;
          ftComp: TValueData(value).FAsSInt64 := jo.AsInteger;
          ftCurr: TValueData(value).FAsCurr := jo.AsCurrency;
        end;
      end;
      Result:= True;
    end;
    jtString:
    begin
      if ISO8601DateToJavaDateTime(jo.AsString, javaDateTime) then
      begin
        value := JavaToDelphiDateTime(javaDateTime);
        Result:= True;
      end
      else
      begin
        jsonTemp.New(jo.AsString);
        try
          if not jsonTemp.IsString then
            Result := FromFloat(aType, jsonTemp, value);
        finally
          jsonTemp.Clear;
        end;
      end;
    end;
  end;
end;

function TJSONUnmarshal.FromChar(const jo: TJSON; var value: TValue): Boolean;
begin
  if jo.IsString and (Length(jo.AsString) = 1) then
  begin
    value := PChar(jo.AsString)^;
    Result := True;
  end else
    Result := False;
end;

function TJSONUnmarshal.FromWideChar(const jo: TJSON; var value: TValue): Boolean;
begin
  if jo.IsString and (Length(jo.AsString) = 1) then
  begin
    value := PWideChar(jo.AsString)^;
    Result := True;
  end else
    Result := False;
end;

function TJSONUnmarshal.FromString(const jo: TJSON; var value: TValue): Boolean;
begin
  case jo.JSONType of
    jtObject, jtArray:
    begin
      Result := False;
//      raise Exception.CreateFmt('Invalid value "%s".', [aJson.ToString]);
    end;
  else
    value:= jo.AsString;
    Result:= True;
  end;
end;

function TJSONUnmarshal.FromRecord(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  field: TRttiField;
  fieldValue: TValue;
  newValue: TJSON;
  isNewValue: Boolean;
  fieldName: string;
  isValid: Boolean;
  instance: Pointer;
begin
  Result:= False;
  if jo.IsObject then
  begin
    if value.IsEmpty then
      TValue.Make(nil, aType, value);
    instance:= value.GetReferenceToRawData;

//    try
      for field in FContext.GetType(aType).GetFields do
      begin
        if field.FieldType <> nil then
        begin
          fieldName:= field.GetFieldName;
          if fieldName = '-' then Continue;   // Field is ignored
          newValue := GetFieldDefault(field, jo[fieldName], isNewValue);
          try
//            try
              fieldValue := field.GetValue(instance);
              isValid:= FromJson(field.FieldType.Handle, newValue, fieldValue);
//            except
//              on E: Exception do
//              begin
//                raise Exception.CreateFmt('UnMarshalling error for field "%s.%s" : %s',
//                                                          [value.AsObject.ClassName, field.Name, E.Message]);
//              end;
//            end;

            if isValid then
            begin
              field.SetValue(instance, fieldValue);
              Result:= True;
            end;
          finally
            if isNewValue then
              newValue.Clear;
          end;
        end;
      end;
//    except
//      raise;
//    end;
  end
end;

function TJSONUnmarshal.FromClass(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  field: TRttiField;
  fieldValue, castValue: TValue;
  jsonValue: TJSON;
  isNewObject: Boolean;
  isNewValue: Boolean;
  fieldName: string;
  isValid: Boolean;
begin
  Result := False;
  if jo.IsObject then
  begin
    if value.IsEmpty then
    begin
      value := CreateInstance(aType);
      isNewObject:= True;
    end else
      isNewObject:= False;

    try
      for field in FContext.GetType(value.AsObject.ClassType).GetFields do
      begin
        if field.FieldType <> nil then
        begin
          fieldName:= field.GetFieldName;
          if fieldName = '-' then Continue;   // Field is ignored
          jsonValue := GetFieldDefault(field, jo[fieldName], isNewValue);
          try
//            try
              fieldValue := field.GetValue(value.AsObject);
              isValid:= FromJson(field.FieldType.Handle, jsonValue, fieldValue);
//            except
//              on E: Exception do
//              begin
//                raise Exception.CreateFmt('UnMarshalling error for field "%s.%s" : %s',
//                                                          [value.AsObject.ClassName, field.Name, E.Message]);
//              end;
//            end;
//            if not fieldValue.IsEmpty then
            if isValid then
            begin
              if fieldValue.TryCast(field.FieldType.Handle, castValue) then
              begin
                field.SetValue(value.AsObject, castValue);
                Result:= True;
              end;
            end;
          finally
            if isNewValue then
              jsonValue.Clear;
          end;
        end;
      end;
    except
      if isNewObject then
      begin
        value.AsObject.Free;
        value := TValue.Empty;
      end;
//      raise;
    end;
  end
  else if jo.IsArray and IsList(aType) and IsParameterizedType(aType) then
  begin
    Result := FromList(aType, jo, value);
  end;
end;

function TJSONUnmarshal.FromList(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  i: Integer;
  rMethod: TRttiMethod;
  jsonValue: TJSON;
  vItem: TValue;
begin
  Result := True;
  if value.IsEmpty then
    value := CreateInstance(aType);

  rMethod := FContext.GetType(aType).GetMethod('Add');

  for i := 0 to jo.Count - 1 do
  begin
    jsonValue := jo[i];

    vItem:= TValue.Empty;
    {vItem := }FromJson(GetParameterizedType(aType).Handle, jsonValue, vItem);

    if not vItem.IsEmpty then
    begin
      rMethod.Invoke(value.AsObject, [vItem]);
    end;
  end;
end;

function TJSONUnmarshal.FromSet(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  i: Integer;
begin
  if jo.IsInteger then
  begin
    TValue.Make(nil, aType, value);
    TValueData(value).FAsSLong := jo.AsInteger;
    Result:= True;
  end else
  if jo.IsString and TryStrToInt(jo.AsString, i) then
  begin
    TValue.Make(nil, aType, value);
    TValueData(value).FAsSLong := i;
    Result:= True;
  end else
    Result := False;
end;

function TJSONUnmarshal.FromArray(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  i: Integer;
  tvArray: array of TValue;
  rttiType: TRttiType;
  elementType: TRttiType;
begin
  if jo.IsNull then
    Exit(False);//(TValue.Empty);

  rttiType := FContext.GetType(aType);

  SetLength(tvArray, jo.Count);
  if rttiType is TRttiArrayType then
    elementType := TRttiArrayType(rttiType).elementType
  else
    elementType := TRttiDynamicArrayType(rttiType).elementType;
  for I := 0 to Length(tvArray) - 1 do
    {Result := }FromJson(elementType.Handle, jo[I], tvArray[I]);
  value:= TValue.FromArray(rttiType.Handle, tvArray);
  Result := True;
end;

function TJSONUnmarshal.FromJson(aType: PTypeInfo; const jo: TJSON; var value: TValue): Boolean;
var
  reverter: TJsonReverter;
begin
  Result:= False;
  if FReverters.TryGetValue(aType, reverter) then
  begin
    if value.IsEmpty and (aType.Kind = tkClass) then
      value:= CreateInstance(aType);
    Result:= reverter(Self, jo, value);
  end else
  case aType.Kind of
    tkChar: Result := FromChar(jo, value);
    tkInt64: Result := FromInt64(aType, jo, value);
    tkEnumeration, tkInteger: Result := FromInt(aType, jo, value);
    tkSet: Result := fromSet(aType, jo, value);
    tkFloat: Result := FromFloat(aType, jo, value);
    tkString, tkLString, tkUString, tkWString: Result := FromString(jo, value);
    tkClass: Result := FromClass(aType, jo, value);
    tkMethod: ;
    tkPointer: ;
    tkWChar: Result := FromWideChar(jo, value);
    tkRecord: Result := FromRecord(aType, jo, value);
//    tkInterface: Result := FromInterface;
    tkArray: Result := FromArray(aType, jo, value);
    tkDynArray: Result := FromArray(aType, jo, value);
//    tkClassRef: Result := FromClassRef;
//  else
//    Result := FromUnknown;
//  else
//    value:= TValue.Empty;
  end;
end;

function TJSONUnmarshal.GetFieldDefault(rttiField: TRttiField; const jo: TJSON; var isNewValue: Boolean): TJSON;
var
  attr: TCustomAttribute;
begin
  if jo.IsNull or (jo.IsString and (jo.AsString = '')) then
  begin
    for attr in rttiField.GetAttributes do
    begin
      if attr is JsonDefault then
      begin
        isNewValue := True;
        Result.New(JsonDefault(attr).Name);
        Exit;
      end;
    end;
  end;

  isNewValue := False;
  Result := jo;
end;

function TJSONUnmarshal.GetParameterizedType(aType: PTypeInfo): TRttiType;
var
  startPos,
  endPos: Integer;
  typeName,
  parameterizedType: String;
begin
  Result := nil;

{$IFDEF NEXTGEN}
  typeName := aType.Name.ToString();
{$ELSE  NEXTGEN}
  typeName := String(aType.Name);
{$ENDIF NEXTGEN}

  startPos := AnsiPos('<', typeName);

  if startPos > 0 then
  begin
    endPos := Pos('>', typeName);

    parameterizedType := Copy(typeName, startPos + 1, endPos - Succ(startPos));

    Result := FContext.FindType(parameterizedType);
  end;
end;

function TJSONUnmarshal.IsList(aType: PTypeInfo): Boolean;
var
  rMethod: TRttiMethod;
begin
  rMethod := FContext.GetType(aType).GetMethod('Add');

  Result := (rMethod <> nil) and
            (rMethod.MethodKind = mkFunction) and
            (Length(rMethod.GetParameters) = 1)
end;

function TJSONUnmarshal.IsParameterizedType(aType: PTypeInfo): Boolean;
var
  i: Integer;
  typeName: string;
  startPos: Integer;
begin
{$IFDEF NEXTGEN}
  typeName := aType.Name.ToString();
{$ELSE  NEXTGEN}
  typeName := String(aType.Name);
{$ENDIF NEXTGEN}
  startPos:= 0;
  for i := 1 to Length(typeName) do
    case typeName[i] of
      '<':
        startPos:= i;
      '>':
        if startPos > 0 then
          Exit(True);
    end;
  Result:= False;
end;

function TJSONUnmarshal.Unmarshal<T>(const jo: TJSON): T;
var
  value: TValue;
begin
  FromJson(TypeInfo(T), jo, value);
  Result := value.AsType<T>;
end;

function TJSONUnmarshal.Unmarshal<T>(const jo: TJSON; var obj: T): Boolean;
var
  value: TValue;
begin
  value:= TValue.From<T>(obj);
  Result:= FromJson(TypeInfo(T), jo, value);
  obj := value.AsType<T>;
end;


{ TJsonAttribute }

constructor TJsonAttribute.Create(const AName: string);
begin
  FName:= AName;
end;


{ TRttiFieldHelper }

function TRttiFieldHelper.FormatUsingISO8601: Boolean;
var
  attr: TCustomAttribute;
begin
  for attr in GetAttributes do
    if attr is JsonISO8601 then
    begin
      Exit(True);
    end;

  Result := False;
end;

function TRttiFieldHelper.GetFieldName: string;
var
  attr: TCustomAttribute;
begin
  for attr in GetAttributes do
    if attr is JsonName then
    begin
      Exit(JsonName(attr).Name);
    end;

  Result := Name;
end;


{ TJSONHelper }

class function TJSONHelper.Marshal<T>(const data: T; mar: TJSONMarshal): TJSON;
var
  value: TValue;
  isOwned: Boolean;
begin
  if mar = nil then
  begin
    mar := TJSONMarshal.Create;
    isOwned:= True;
  end else
    isOwned:= False;

  try
    Result:= mar.ToJSON(nil, TValue.From<T>(data));
  finally
    if isOwned then
      mar.Free;
  end;
end;

class function TJSONHelper.MarshalIndent<T>(const data: T; const Indent: string; mar: TJSONMarshal): string;
var
  jo: TJSON;
begin
  jo:= Marshal<T>(data, mar);
  Result:= jo.AsJSONIndent(Indent);
  jo.Clear;
end;

class function TJSONHelper.Unmarshal<T>(var data: T; const json: TJSON; unmar: TJSONUnmarshal): Boolean;
var
  value: TValue;
  isOwned: Boolean;
begin
  if unmar = nil then
  begin
    unmar := TJSONUnmarshal.Create;
    isOwned:= True;
  end else
    isOwned:= False;

  try
    value:= TValue.From<T>(data);
    Result := unmar.FromJson(TypeInfo(T), json, value);
    if Result then
      data:= value.AsType<T>;
  finally
    if isOwned then
      unmar.Free;
  end;
end;

class function TJSONHelper.Unmarshal<T>(var data: T; const json: string; unmar: TJSONUnmarshal): Boolean;
var
  jo: TJSON;
begin
  jo.New(json);
  Result:= Unmarshal<T>(data, jo, unmar);
  jo.Clear;
end;


class function TJSONHelper.Unmarshal<T>(const json: TJSON; unmar: TJSONUnmarshal): T;
var
  value: TValue;
  isOwned: Boolean;
begin
//  Result:= Default(T);
//  Unmarshal<T>(Result, json, unmar);
  if unmar = nil then
  begin
    unmar := TJSONUnmarshal.Create;
    isOwned:= True;
  end else
    isOwned:= False;

  try
    if not unmar.FromJson(TypeInfo(T), json, value) then
      raise Exception.Create('Invalid object');
    Result := value.AsType<T>;
  finally
    if isOwned then
      unmar.Free;
  end;
end;

class function TJSONHelper.Unmarshal<T>(const json: string; unmar: TJSONUnmarshal): T;
var
  jo: TJSON;
begin
  jo.New(json);
  Result:= Unmarshal<T>(jo, unmar);
  jo.Clear;
end;


{ TSuperObjectHelper }

function TJSONObjectHelper.Marshal(mar: TJSONMarshal = nil): TJSON;
var
  value: TValue;
  isOwned: Boolean;
begin
  if mar = nil then
  begin
    mar := TJSONMarshal.Create;
    isOwned:= True;
  end else
    isOwned:= False;

  try
    value:= Self;
    Result:= mar.ToJSON(nil, value);
  finally
    if isOwned then
      mar.Free;
  end;
end;

function TJSONObjectHelper.MarshalIndent(mar: TJSONMarshal = nil; const Indent: string = '  '): string;
var
  jo: TJSON;
begin
  try
    jo:= Marshal(mar);
    Result:= jo.AsJSONIndent(Indent);
  finally
    jo.Clear;
  end;
end;

constructor TJSONObjectHelper.Unmarshal(const jsonObj: TJSON; unmar: TJSONUnmarshal = nil);
var
  value: TValue;
  isOwned: Boolean;
begin
  if unmar = nil then
  begin
    unmar := TJSONUnmarshal.Create;
    isOwned:= True;
  end else
    isOwned:= False;

  try
    value:= Self;
    if not unmar.FromJson(value.TypeInfo, jsonObj, value) then
      raise Exception.Create('Invalid object');
  finally
    if isOwned then
      unmar.Free;
  end;
end;

constructor TJSONObjectHelper.Unmarshal(const jsonText: string; unmar: TJSONUnmarshal = nil);
var
  jo: TJSON;
begin
  try
    jo.New(jsonText);
    Unmarshal(jo, unmar);
  finally
    jo.Clear;
  end;
end;


end.

