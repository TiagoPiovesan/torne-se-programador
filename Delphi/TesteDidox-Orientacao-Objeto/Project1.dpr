program Project1;

uses
  Forms,
  untForm1 in 'untForm1.pas' {Form1},
  untClass in 'untClass.pas',
  CLMedia in 'CLMedia.pas',
  CLMediaPonderada in 'CLMediaPonderada.pas',
  Unit2 in 'Unit2.pas' {Form2},
  IType in 'IType.pas',
  Cliente in 'Cliente.pas',
  List in 'List.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
