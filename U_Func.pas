unit U_Func;

interface

type
  TFunc = class
  public
    class function IfThen(AValue: Boolean; const ATrue: variant;
      const AFalse: variant): variant;
  end;

implementation

{ TFunc }

class function TFunc.IfThen(AValue: Boolean; const ATrue,
  AFalse: variant): variant;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
  //
end;

end.
