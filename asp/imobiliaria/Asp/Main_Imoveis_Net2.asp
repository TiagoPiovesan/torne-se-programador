<!--#INCLUDE FILE ="chamar_banco.asp"-->
<!--#INCLUDE FILE ="funcao_senha.asp"-->
<!--#INCLUDE FILE ="CPF_CNPJ.asp"-->
<!--#include file="aDOVBS.inc" -->
<%
tipo_imovel=request("tipo_imovel")
subtipo_imovel=request("subtipo_imovel")
codigo=request("codigo")
pagina=request("pagina")
servico=request("servico")
cod_estado=request("cod_estado")
cod_cidade=request("cod_cidade")
cod_cliente=request("cod_cliente")


'********Customiza��o para verificar o endere�o de acordo com o cep fornecido no passo anterior********
'Autor: Bolonha
'Data: 12/09/2005
'Primeiro verifico o endere�o do cep fornecido no banco de dados enderecos.mdb, em seguida verifico se
'o bairro do cep fornecido est� cadastrado no banco do sistema imobiliaria, caso n�o esteja o mesmo ser� 
'cadastrado e em seguida os dados do endere�o do cep fornecido ser� exibido na tela.

If request("flag") <> "1" then

Set cnx = Server.CreateObject("ADODB.Connection")
'cnx.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\cliente\plena\database\enderecos.mdb"
cnx.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=E:\home\bigsolutions-sbs\dados\enderecos.mdb"

Set rsEST = conn.execute("Select descricao from Estado where codigo = "&request("cod_estado")&"")
If not rsEST.eof then
  estado = substest(rsEST("descricao"))
End If
rsEST.close
Set rsEST = nothing



If estado <> "" then

  sqlUF = "Select SiglaUF from [Tabela de UF] where NomeUF = '"&estado&"'"
  'response.write sqlUF
  'response.end 
  Set rsUF = cnx.execute(sqlUF)
  If not rsUF.eof then
    uf  = rsUF("SiglaUF")
  End If
  rsUF.close
  Set rsUF = nothing
  
  If uf <> "" then
    cep = replace(replace(request("cep_imovel"),"-",""),".","")
    
  
    sqlK = "SELECT [Tabela de Bairros].EXTENSOBAI, [Tabela de Localidades].NOMELOC,"
    sqlK = sqlK & " [Tabela de Tipolog].ABREVPAT, [Tabela Log"&uf&"].NOMELOG"
    sqlK = sqlK & " FROM ([Tabela Log"&uf&"] INNER JOIN ([Tabela de Localidades]"
    sqlK = sqlK & " INNER JOIN [Tabela de Bairros] ON [Tabela de Localidades].CHAVELOC = [Tabela de Bairros].CHVLOCBAI)"
    sqlK = sqlK & " ON ([Tabela Log"&uf&"].CHVLOCLOG = [Tabela de Localidades].CHAVELOC)"
    sqlK = sqlK & " AND ([Tabela Log"&uf&"].CHVBAILOG1 = [Tabela de Bairros].CHAVEBAI))"
    sqlK = sqlK & " INNER JOIN [Tabela de Tipolog] ON [Tabela Log"&uf&"].CHVPATLOG = [Tabela de Tipolog].CHAVEPAT"
    sqlK = sqlK & " WHERE [Tabela Log"&uf&"].CEPLOG = "&cep&" AND [Tabela de Bairros].UFBAI='"&uf&"'"
    'response.write sqlK
    'response.end
  
    Set rsLog = cnx.execute(sqlK)
  
    If not rsLog.eof then
      'response.write(replace(rsLog("ABREVPAT")," ","") &" "& rsLog("NOMELOG"))&"<br>"
	  'response.write(rsLog("EXTENSOBAI"))&"<br>"
	  'response.write(rsLog("NOMELOC"))&"<br>"
	  'response.end
	  
      endereco = replace(rsLog("ABREVPAT")," ","") &" "& rsLog("NOMELOG")
      bairro = rsLog("EXTENSOBAI")
      cidade = rsLog("NOMELOC")
      
      Set rsBai = conn.execute("Select * from Bairro where descricao = '"&bairro&"' and cod_cidade = "&cod_cidade&"")

	  If rsBai.eof then
       conn.execute("insert into Bairro (cod_cidade, descricao, status) values ("&cod_cidade&", '"&bairro&"', 0)")

      End If
      rsBai.close
      Set rsBai = nothing
      
    End If
  
    rsLog.close
    Set rsLog = nothing
  End If
End If

cnx.close
Set cnx = nothing

End If

'********Fim da Customiza��o********

set cliente=conn.execute("select * from registro_cliente_imovel where codigo="&codigo)

if request("flag") = "1" then
   If subtipo_imovel = "" then
     subtipo_imovel      =cliente("subtipo")
   End if
   bairro       =request("bairro")
   endereco     =replace(trim(ucase(request("endereco"))),"'","")
   numero       =replace(trim(ucase(request("numero"))),"'","")
   complemento  =replace(trim(ucase(request("complemento"))),"'","")
   condominio   =replace(trim(ucase(request("condominio"))),"'","")
   categoria    =request("categoria")
   valor_imovel =request("valor_imovel")
   divida       =request("divida")
   if request("dormitorio") <> "" then
   dormitorio   =request("dormitorio")
   else
   dormitorio = 0
   end if
   suites       =request("suites")
   garagem      =request("garagem")
   idade        =request("idade")
   
   Set codim = conn.execute("Select codigo from imoveis order by codigo DESC")  

   cod_imovel = codim("codigo") + 1

   codim.close
   Set codim = nothing
 
   if valor_imovel <> "" then
   sqlins = "INSERT INTO Perfil_Servico (cod_moeda, cod_imovel, cod_servico, valor) VALUES (7, "&cod_imovel&", "&cliente("transacao")&", "&replace(replace(request("valor_imovel"),".",""),",",".")&")"
   'response.write sqlins
   'response.end 
    
   conn.execute(sqlins)
   end if

   if bairro="" then
      msg=msg& "&nbsp; Bairro.<br>"
   end if
   if Endereco="" then
      msg=msg& "&nbsp; Endere�o.<br>"
   end if
   if numero= "" then
     msg=msg& "&nbsp; N�mero.<br>"
   end if
   if Categoria="0" or Categoria="" then
    msg=msg& "&nbsp; Categoria.<br>"
   end if
   if valor_imovel="" then
      msg=msg& "&nbsp; Valor R$.<br>"
   end if   
   'if dormitorio="" or dormitorio="0" then
   '   msg=msg& "&nbsp; Dormit�rio.<br>"
   'end if
   if idade="" or idade="0" then
      msg=msg& "&nbsp; Idade do Im�vel.<br>"
   end if
   if divida = "" then
      divida = 0
   end if

   set plano = conn.execute("select * from Perfil_plano where cod_imovel="&codigo)
   if msg="" and reload="" then
      if filename<>"" then
         Set MyFile = ScriptObject.CreateTextFile(server.mappath("../fotos/"&filename))
         For i = 1 to LenB(value)
             MyFile.Write chr(AscB(MidB(value,i,1)))
         Next
         MyFile.Close
      end if
      sqlins = "insert into Imoveis (descricao, endereco,numero,complemento,cod_bairro,data_inclusao,status,valor_imovel,dormitorio,suites,cod_idade_imovel,garagem,divida,cod_categoria, cod_cidade, cod_estado, cod_cliente, tipo_imovel, subtipo_imovel, publicar)values ('"&condominio&"','"&endereco&"','"&numero&"','"&complemento&"',"&bairro&",convert(datetime,'"&date()&"',103),2,"&replace(replace(request("valor_imovel"),".",""),",",".")&",'"&dormitorio&"','"&suites&"',"&idade&",'"&garagem&"', "&divida&","&categoria&", "&cod_cidade&", "&cod_estado&", "&cod_cliente&", "&tipo_imovel&", '"&subtipo_imovel&"', 0)"
      'response.write sqlins
      'response.end
      conn.execute(sqlins)
      set cod_imovel=conn.execute("select * from imoveis where endereco='"&endereco&"' and numero='"&numero&"' and complemento='"&complemento&"' and cod_bairro="&bairro&" and data_inclusao=convert(datetime,'"&date()&"',103) and status=2 and valor_imovel="&replace(replace(request("valor_imovel"),".",""),",",".")&" and dormitorio='"&dormitorio&"' and suites='"&suites&"' and cod_idade_imovel="&idade&" and garagem='"&garagem&"' and divida="&divida&" and cod_categoria="&categoria&" order by codigo desc")
      conn.execute("insert into Cliente_imovel_net (cod_imovel, cod_cliente_imovel)values("&cod_imovel("codigo")&","&codigo&")")
      %>
        <script>
           alert('Im�vel cadastrado com sucesso!');
           location.href="Main_Imoveis_Net3.asp?codigo=<%=codigo%>&cod_imovel=<%=cod_imovel("codigo")%><%if trim(request("str")) = trim("cad") then%>&str=cad<%end if%>";
        </script>
   <%end if
end if%>
<html>
<head>
<title>:::::Imobi....:::</title>
<script language="javascript" src="formatacao.js"></script>
<link rel="stylesheet" href="estilo.css" type="text/css">
<meta name="description" content="BIG SOLUTIONS TECNOLOGIA DA INFORMA��O LTDA">
</head>
<body marginheight="0" marginwidth="0" leftmargin=0 topmargin=0 bgcolor="#F4F2EA" text="#333333" link="#333333" vlink="#333333" alink="#333333">
<table border="0" width="777" cellspacing="0" cellpadding="0" height="100%">
  <tr>
    <td>
        <!--#INCLUDE FILE ="Main_Topo.asp"-->      
          <table width="99%"  border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
              <td><table width=100% class="tabela001">
          <form method=post action="<%=request.servervariables("SCRIPT_NAME")%>?flag=1&pagina=<%=pagina%>&currentPage=<%=currentPage%>&codigo=<%=codigo%>&cod_cidade=<%=cod_cidade%>&cod_estado=<%=cod_estado%>&tipo_imovel=<%=tipo_imovel%>&cod_cliente=<%=cod_cliente%><%if request("str") = "cad" then%>&str=cad<%end if%>" name="form1">
           <input type=hidden name="reload">
           <input type=hidden name="excluir">
           <input type="hidden" name="Categoria" value="<%=request("categoria")%>">
            <tr><td></td></tr>
          </table></td>
		  <tr>
          <td><table width=100% border=0 cellpadding="0" cellspacing="0" class="tabela002">
            <tr> 
              <td width=20><img src="../img/r_8.gif"></td>
              <td class="tb"><B>CADASTRAR IM�VEL</B>&nbsp;</td>
            </tr>
          </table>  </td>
		  </tr></table>
		  
          <%

		  If request("str") = "cad" then%>
          <%End If%>
         <br><br><br>
        <table width=98% border="0" align=center cellpadding="0" cellspacing="0">
        <tr>
          <td>
            <table cellspacing=0 cellpadding=0>
              </tr>
            </table>          </td>
        </tr>
        <tr>
          <td height="19" colspan=2>
            <span class="estilo">CEP:          </td>
        </tr>
        <tr>
          <td height="19" colspan=2>
            &nbsp;&nbsp;<span class="estilo"><%=cliente("cep_imovel")%>          </td>
        </tr>
        <tr>
          <td colspan=2>
            <img src="../img/obrigacao.gif">&nbsp;<span class="estilo">Bairro:          </td>
        </tr>
        <tr>
          <td colspan=2>
            <table cellspacing=0 cellpadding=0>
              <tr>
                <td>
				  <%
				StrSelCid = "Select * from Cidade where codigo = "&cliente("cidade")
                set rsSelCid = conn.execute(StrSelCid)
				
				uf2 =  rsSelCid("descricao")
				'***************Normaliza��o***********************
				'Tabela de Estados n�o contem UF
				'**************************************************
				
				strUF = "select UF from UF where codigo = "& cliente("estado")

				set rsUF = conn.execute(strUF)
				
				if not rsUF.eof then
				uf2 =  rsUF("UF")
				Else
				uf2 = ""
				End if
				
				cep2 = replace(replace(cliente("cep_imovel"),"-",""),".","")

				Set cnx = Server.CreateObject("ADODB.Connection")
				cnx.open "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=E:\home\bigsolutions-sbs\dados\enderecos.mdb"

				sqlK2 = "SELECT [Tabela de Bairros].EXTENSOBAI, [Tabela de Localidades].NOMELOC,"
			    sqlK2 = sqlK2 & " [Tabela de Tipolog].ABREVPAT, [Tabela Log"&uf2&"].NOMELOG"
			    sqlK2 = sqlK2 & " FROM ([Tabela Log"&uf2&"] INNER JOIN ([Tabela de Localidades]"
			    sqlK2 = sqlK2 & " INNER JOIN [Tabela de Bairros] ON [Tabela de Localidades].CHAVELOC = [Tabela de Bairros].CHVLOCBAI)"
			    sqlK2 = sqlK2 & " ON ([Tabela Log"&uf2&"].CHVLOCLOG = [Tabela de Localidades].CHAVELOC)"
			    sqlK2 = sqlK2 & " AND ([Tabela Log"&uf2&"].CHVBAILOG1 = [Tabela de Bairros].CHAVEBAI))"
			    sqlK2 = sqlK2 & " INNER JOIN [Tabela de Tipolog] ON [Tabela Log"&uf2&"].CHVPATLOG = [Tabela de Tipolog].CHAVEPAT"
			    sqlK2 = sqlK2 & " WHERE [Tabela Log"&uf2&"].CEPLOG = "&cep2&" AND [Tabela de Bairros].UFBAI='"&uf2&"'"

                 Set rsCEP= cnx.execute(sqlK2)
				 
				 IF rsCEP.EOF THEN
				 %>
				 <SCRIPT>
				 alert('CEP n�o encontrado.');
				 history.go(-2);
				 </SCRIPT>
				 <%
				 END IF
				 '===================Aten��o==================='
				 'Aqui traz o bairro selecionado a partir do cep


				 strBaiSel = "Select * from bairro where descricao = '" & rsCEP("EXTENSOBAI") &"'"
			     set rsBaiSel  = conn.execute(strBaiSel)
				 if not rsBaiSel.eof then
				 %>
				 <select name="bairro"  size=5>
				 <option value="<%=rsBaiSel("codigo")%>"selected><%=rsBaiSel("descricao")%>
				 </select>
				 <%
				 else
				  %>
				  <select name="bairro"  size=5>
                    <%
					set cbai=conn.execute("select * from bairro where cod_cidade="&cliente("cidade")&" ORDER BY descricao")%>
                    <%do while not cbai.eof %>
                         <option value="<%=cbai("codigo")%>" <%if UCase(cbai("codigo"))=UCase(bairro) or UCase(cbai("descricao"))=UCase(bairro) OR UCase(cbai("descricao")) = TRIM(rsCEP("EXTENSOBAI")) then%>selected<%end if%>><%=cbai("descricao")%>
                      <%cbai.movenext%>
                    <%loop%>
                  </select>                
				  <%
				  End if
				  %>
				  </td>
              </tr>
            </table>          </td>
        </tr>
        <tr>
          <td colspan=2>
            <img src="../img/obrigacao.gif">&nbsp;<span class="estilo">&nbsp;Endere�o:          </td>
        </tr> 
        <tr>
          <td colspan=2><input type="text" name="endereco" value="<%=endereco%>" label="valor" style="width:290; height:17;" maxlength="50"></td>
        </tr>
        <tr>
          <td> 
            <img src="../img/obrigacao.gif">&nbsp;<span class="estilo">&nbsp;N�mero:          </td>
        </tr> 
        <tr>
          <td>
            <input type="text" name="numero" value="<%=numero%>" label="valor" style="width:70; height:17;" maxlength="50">(N�o ser� informado no an�ncio.)          </td>
        </tr> 
        <tr>
          <td>
            <span class="estilo">&nbsp;Complemento:          </td>
        </tr> 
        <tr>
          <td>
            <input type="text" name="Complemento" value="<%=Complemento%>" label="valor" style="width:100; height:17;" maxlength="50">(N�o ser� informado no an�ncio.)          </td>
        </tr>
        <tr>
          <td>
            <span class="estilo">&nbsp;Nome do Condom�nio:          </td>
        </tr> 
        <tr>
          <td>
            <input type="text" name="condominio" value="<%=condominio%>" label="valor" style="width:290; height:17;" maxlength="50">          </td>
        </tr>
      
        <tr>
          <td colspan=2>
            <table border=0 cellpadding="0" cellspacing="0">
      <tr>
       <td>
        <img src="../img/obrigacao.gif">&nbsp;<span class="estilo">&nbsp;Valor R$:       </td>
      </tr>
      <tr>
        <td>
        <input type="text" name="valor_imovel" value="<%=valor_imovel%>" label="valor" style="width:100; height:17;text-align: RIGHT;" maxlength="18" onKeyPress="Numero();" onKeyUp="Moeda(this);">&nbsp;&nbsp;&nbsp;&nbsp;        </td>
      </tr>
      <tr>
        <td>
           <%if divida = "0" or divida = "" then%>
             <input type="checkbox" name="divida" value="1"  label="suites" ><span class="estilo">Im�vel com d�vida.</span>
           <%else%>
             <input type="checkbox" name="divida" value="1"  checked label="suites" ><span class="estilo">Im�vel com d�vida.</span>
           <%end if%>        </td>
      </tr>
      <tr>
       <td>
        &nbsp;&nbsp;<span class="estilo">&nbsp;N� Domit�rios:       </td>
       <td>
        <span class="estilo">&nbsp;Sendo Suites:       </td>
      </tr>
      <tr>
        <td>
          <select name="dormitorio" >
            <%if dormitorio = "0" or dormitorio = "" then%>
       	        <option value = "0">Nenhuma</option>
       	    <%else%>
       	        <option value="<%=dormitorio%>" selected><%=dormitorio%>
       	    <%end if%>
            <option value = "1">1</option>
            <option value = "2">2</option>
            <option value = "3">3</option>
            <option value = "4">4</option>
            <option value = "5">5</option>
            <option value = "6">6</option>
            <option value = "7">7</option>
          </select>        </td>
        <td>
          <select name="Suites" >
            <%if suites = "0" or suites = "" then%>
       	        <option value = "0">Nenhuma</option>
       	    <%else%>
       	        <option value="<%=suites%>" selected><%=suites%>
       	    <%end if%>
            <option value = "1">1</option>
            <option value = "2">2</option>
            <option value = "3">3</option>
            <option value = "4">4</option>
            <option value = "5">5</option>
            <option value = "6">6</option>
            <option value = "7">7</option>
          </select>        </td>
      </tr>
      <tr>
       <td>
        <span class="estilo">&nbsp;Vagas de Garagem:       </td>
      </tr>
      <tr>
        <td>
          <select name="garagem" >
            <%if garagem = "0" or garagem = "" then%>
       	        <option value = "0">Nenhuma</option>
       	    <%else%>
       	        <option value="<%=garagem%>" selected><%=garagem%>
       	    <%end if%>
            <option value = "1">1</option>
            <option value = "2">2</option>
            <option value = "3">3</option>
            <option value = "4">4</option>
            <option value = "5">5</option>
          </select></td>
      </tr>
        </table>        </td>
      </tr> 
      <tr>
        <td colspan=2>
          <img src="../img/obrigacao.gif">&nbsp;<span class="estilo">&nbsp;Idade do Im�vel:        </td>
      </tr>
      <tr>
        <td colspan=2>
          <select name="idade" >
            <option value = "0">(Selecione)</option>
              <%set cbai=conn.execute("select * from tipo_idade_imovel where status=0 ORDER BY codigo")%>
              <%do while not cbai.eof %>
                <%if cstr(cbai("codigo"))=cstr(idade) then%>
                  <option value="<%=cbai("codigo")%>" selected><%=cbai("descricao")%>
                <%else%>
                  <option value="<%=cbai("codigo")%>"><%=cbai("descricao")%>
                <%end if%>
                <%cbai.movenext%>
               <%loop%>
          </select>        </td>
      </tr>
      <tr>
        <td colspan=2>
         <table border=0>
          <tr>
           <td>
             <br><input type="image" value="submit" src="../../imagens/botoes/GRAVAR1.gif" width="86" height="26" border=0>           </td>
          </tr>
        </table>      </td>
    </tr>
    </td>
  </tr>
</table>
</form>
</body>
</html>

