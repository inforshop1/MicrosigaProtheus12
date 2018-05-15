#include "Directry.ch"
#Include "RWMAKE.Ch"
#include "ap5mail.ch"
#Include "Topconn.ch"
#DEFINE ENTER Chr(13)+Chr(10)     
#DEFINE CRLF Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A010TOK  ³ Autor ³ Milton Nishimoto      ³ Data ³ 17/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Ponto de entrada apos gravacao do produto, bloqueia o pro- ³±±
±±³Descri‡…o ³ duto incluido e nao deixa alterar enqto nao seja inserida  ³±±
±±³Descri‡…o ³ a foto do produto na pasta sigaadv\fotos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Inforshop                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function a010tok()
//Local _lInclui 		:= .T.
Local _Desc		   :='Novo produto cadastrado, código '+M->B1_COD+'- '+M->B1_DESC+'. Verifique as informações.'
Local aFotos	   :={}
Local areaSB1	   :=GetArea()
Local _Emailcomp   :=""
Local cEmail       :="contratos@inforshop.com.br;compras@inforshop.com.br"
Local cCodUsu      :=RetCodUsr()
Local _cMAILLIBFIS :="camila.brito@inforshop.com.br;fernando.sampaio@inforshop.com.br " //solicitação de mudança por Marcio conform chamado 043598
//Local _cMAILLIBFIS :=	"marcio.maritan@inforshop.com.br;rogerio.libarino@inforshop.com.br;camila.brito@inforshop.com.br;fernando.sampaio@inforshop.com.br "
Private cEmailAdm  :=GETMV("MV_WFADMIN")
Private cEmallogs  :="protheus@inforshop.com.br;fiscal@inforshop.com.br;sergio.varjao@inforshop.com.br"   
Private cEmalecomm :="protheus@inforshop.com.br;ecommerce@inforshop.com.br" 
Private cQuery     :="" 
Private cMensl     :=""  
Private cDseman    :=""  


If INCLUI 													//Na inclusao, bloqueia e envia email para o fiscal e para os Compradores
	Alert('Produto incluído bloqueado.Inclua a foto pela intranet e desbloqueie! - A010TOK')
	//1=SIM,BLOQUEADO;2=NAO,LIBERADO
	M->B1_MSBLQL	:= '1'
	//Verifica email do comprador
	If M->B1_GRUPCOM <> ''
		DbSelectArea("SAJ")
		DbSetOrder(1)
		If DbSeek(xFilial("SAJ")+M->B1_GRUPCOM)
			While AJ_GRCOM == M->B1_GRUPCOM
				_Emailcomp	+= AllTrim(UsrRetMail(SAJ->AJ_USER))+';'
				SAJ->(DbSkip())
			EndDo
		Else
			_EmailComp	:= "compras@inforshop.com.br;"
		EndIf
		SAJ->(DbCloseArea())
	Else
		_EmailComp	:= "compras@inforshop.com.br;"
	EndIf
	//RestArea(areaB1)
	U_ENVMAIL('avisos@inforshop.net.br',_cMAILLIBFIS+";"+_EmailComp+'fiscal@inforshop.com.br','',_Desc,'Novo produto cadastrado','')
	//Se for produto para a internet inclui um registro na tabela de preco TABELA SITE
	If M->B1__INTERN == '1'
		//		U_Site008(M->B1_COD)		//Funcao que inclui o produto na tabela de precos SITE
	EndIf
	
	//BLOQUEIO FISCAL NA INCLUSÃO
	M->B1__BLQFIS := "S"
	
EndIf

IF ALTERA 

   LOGALT() //CHAMADA DA FUNCAO RESPONSAVEL PELO ENVIOU DOS LOGS
   
ENDIF

//Nao deixa alterar se o produto nao estiver com a foto preenchida
If Altera .And.  SB1->B1_MSBLQL == '1' .And. M->B1__BLQFIS # "S"
	aFotos		:= DIRECTORY(ALLTRIM(GETMV("MV_DIRFOTO"))+'*.JPG', "D")
	
	If AScan(aFotos,{|x| UPPER(alltrim(x[1])) == ALLTRIM(M->B1_COD)+'.JPG' }) == 0
		Alert('Para desbloquear o produto é preciso antes incluir a foto do produto via INTRANET. - A010TOK')
		M->B1_MSBLQL	:= '1'
		Return
	Endif

ElseIf ALTERA

	IF M->B1__BLQFIS == "S"
        //DEIXAR ESTA VERIFICACAO PRIMEIRO
		IF U_CHECKGRUPO("Fiscal") //PERTENCE AO GRUPO FISCAL   
		
			RecLock("SB1",.F.)
			SB1->B1__BLQFIS := "N"
			SB1->(MsUnlock())
			
			cMensagem := "O Produto abaixo foi liberado pelo Departamento Fiscal"+ENTER
			cMensagem += "Produto  :"+M->B1_COD+ENTER
			cMensagem += "Descrição:"+M->B1_DESC+ENTER
			cMensagem += "Marca    :"+M->B1_PYMARCA	+ENTER
			U_ENVMAIL('avisos@inforshop.net.br',_cMAILLIBFIS,'',cMensagem,'Produto '+M->B1_COD+' Liberado pelo Depto. Fiscal - '+Dtoc(Date()) ,"")
		ELSE
			MsgStop("Produto necessita ser desbloqueado pelo Depto. Fiscal.","A010TOK")
			M->B1__BLQFIS := "S"
			M->B1_MSBLQL	:= '1'
			Return(.F.)
 		ENDIF
	ENDIF 
	
	IF M->B1__BLQFIS == "N"
        //DEIXAR ESTA VERIFICACAO PRIMEIRO
		IF U_CHECKGRUPO("Fiscal") //PERTENCE AO GRUPO FISCAL  	 
			
			RecLock("SB1",.F.)
			SB1->B1__BLQFIS := "S"
			SB1->(MsUnlock())
		
			cMensagem := "O Produto abaixo foi bloqueado pelo Departamento Fiscal"+ENTER
			cMensagem += "Produto  :"+M->B1_COD+ENTER
			cMensagem += "Descrição:"+M->B1_DESC+ENTER
			cMensagem += "Marca    :"+M->B1_PYMARCA	+ENTER
			U_ENVMAIL('avisos@inforshop.net.br',_cMAILLIBFIS,'',cMensagem,'Produto '+M->B1_COD+' Liberado pelo Depto. Fiscal - '+Dtoc(Date()) ,"")

 		ENDIF
	ENDIF

    
		//QUANDO TIVER AUMENTO DE IMPOSTO GERA REGISTRO DE APROVACAO
	If M->B1__IPI > 0 .Or. M->B1__ICMS > 0
		//VERIFICA SE JA EXISTE UM REGISTRO SEM APROVACAO E O ALTERA
		cQuery := " SELECT * FROM "+RetSqlName("SZN")
		cQuery += " WHERE ZN_CODPRO = '"+M->B1_COD+"'"
		cQuery += " AND D_E_L_E_T_ <> '*' AND ZN_APROV = ''"
		cQuery += " AND ZN_TIPO = 'F'"
		
		MEMOWRITE("A010TOK.sql",cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCM0",.T.,.T.)
		
		Count To nRec1
		
		If nRec1 > 0
			dbSelectArea("TRBCM0")
			dbGoTop()
			
			dbSelectArea("SZN")
			dbSetOrder(3)
			If dbSeek(xFilial()+TRBCM0->ZN_COD)
				RecLock("SZN",.F.)
				ZN_PRCCOM 	:= 0
				ZN_DATA		:= dDataBase
				ZN_USERINC  := SubStr(cUsuario,7,15)
				ZN_HRINC    := Time()
				ZN_PICM		:= M->B1__ICMS
				ZN_IPI		:= M->B1__IPI

				SZN->(MsUnlock())
			EndIf
			//CASO NAO TENHA SIDO ALTERADO, INCLUI
		Else
			dbSelectArea("SZN")
			cNumSZN := NextNumero("SZN",3,"ZN_COD",.T.) //GetSx8Num("SZN","ZN_COD")
			RecLock("SZN",.T.)
			ZN_FILIAL 	:= xFilial()
			ZN_COD		:= cNumSZN
			ZN_CODTAB	:= ""
			ZN_CODFOR	:= M->B1_PROC
			ZN_CODPRO	:= M->B1_COD
			ZN_PRCCOM 	:= 0
			ZN_DATA		:= dDataBase
			ZN_USERINC  := SubStr(cUsuario,7,15)
			ZN_HRINC    := Time()
			ZN_TIPO 	:= "F"
			ZN_IPI		:= M->B1__IPI
			ZN_PICM		:= M->B1__ICMS
			
			//EFETUA A PERGUNTA DE ANEXO
			If MsgYesNo("Você alterou um imposto, deseja inserir um anexo que comprove o aumento?","CM010TOK")
				U_SelArqSQL('SZN'+SZN->ZN_FILIAL+SZN->ZN_CODPRO+SZN->ZN_COD,.T.,.T.)
				cChave := 'SZN'+SZN->ZN_FILIAL+SZN->ZN_CODPRO+SZN->ZN_COD				
				SZN->ZN_ANEXO := "S"
			EndIf
			
			SZN->(MsUnlock())
			//SZN->(ConfirmSX8())
			
		EndIf
		TRBCM0->(dbCloseArea())
	EndIf

	//SOMENTE O GERENTE DE COMPRAS PODE BLOQUEAR UM ITEM
	If M->B1_MSBLQL == "1" .And. !cCodUsu $ GetMV("MV_IBLQPER")//"000000|000045|000247"//ADMINISTRADOR|ROGERIO.LIBARINO|TATIANE.GONCALVES
		MsgStop("Usuário sem premissão para bloquear um produto!","A010TOK")
		Return
	EndIf
	_cProduto := SB1->B1_COD
	M->B1_ULTREVI := Date()
	//quando estiver bloqueado envia e-mail de aviso
	IF M->B1_MSBLQL == "1" .And. SB1->B1_MSBLQL # '1'
		cMensagem := "O Produto abaixo está bloqueado para vendas"+ENTER
		cMensagem += "Produto  :"+_cProduto+ENTER
		cMensagem += "Descrição:"+M->B1_DESC+ENTER
		cMensagem += "Marca    :"+M->B1_PYMARCA	+ENTER
		U_ENVMAIL('avisos@inforshop.net.br',cEmail,'',cMensagem,'Produto Bloqueado para Vendas - '+Dtoc(Date()) ,"")
	ElseIf M->B1_SITPROD == "RE" .And. SB1->B1_SITPROD # "RE"
		cMensagem := "O Produto abaixo estará dispnível para vendas até o término do saldo em estoque"+ENTER
		cMensagem += "Produto  :"+_cProduto+ENTER
		cMensagem += "Descrição:"+M->B1_DESC+ENTER
		cMensagem += "Marca    :"+M->B1_PYMARCA	+ENTER
		U_ENVMAIL('avisos@inforshop.net.br',cEmail,'',cMensagem,'Produto com Restrição para Vendas - '+Dtoc(Date()) ,"")
	EndIf
Endif

//ATUALIZA A DESCRICAO DOS CODIGOS DE BARRAS
cQuery := " UPDATE "+RetSqlName("Z06")
cQuery += " SET Z06_DESCRI = '"+M->B1_DESC+"'
cQuery += " WHERE Z06_PRODUT = '"+M->B1_COD+"'"

If TcSqlExec(cQuery) <0
	UserException( "Erro na atualização"+ Chr(13)+Chr(10) + "Processo com erros"+ Chr(13)+Chr(10) + TCSqlError() )
EndIf

//ATUALIZA A DESCRICAO DA POLITICA DE PRECO
cQuery := " UPDATE "+RetSqlName("SZZ")
cQuery += " SET ZZ_PYDESCR = '"+M->B1_DESC+"'
cQuery += " WHERE ZZ_PYCOD = '"+M->B1_COD+"'"

If TcSqlExec(cQuery) <0
	UserException( "Erro na atualização"+ Chr(13)+Chr(10) + "Processo com erros"+ Chr(13)+Chr(10) + TCSqlError() )
EndIf

If Altera .And. M->B1__INTERN == '1'
	//	U_Site008(M->B1_COD)  //Funcao que atualiza a tabela de preco Site
	//Marca o campo B1__ALTINT como sim, para ser atualizado no site
	//	U_Site002(M->B1_COD)
EndIf

If Altera .And. M->B1__INTERN <> '1'
	DbSelectArea('DA1')
	DbSetOrder(2)
	If DbSeek(xFilial("DA1")+M->B1_COD+'INT')
		RecLock("DA1",.F.)
		DbDelete()
		DA1->(MsUnLock())
		//		U_Site002(M->B1_COD)
	EndIf
EndIf  

RestArea(areaSB1)
Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CHECKGRUPO³ Autor ³ CARLOS SILVA          ³ Data ³ 17/06/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ESTA FUNCAO TEM COMO PREMISSA ANALISAR SE O USUARIO POSSUI  ³±± 
±±³          ³PERMISSAO PARA ALTERAR ALGUMAS OPCOES NA ROTINA.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Carlos Silva³17/06/14³30213 ³Correcao para tratamento de buscao de     ³±±  
±±³            ³        ³      ³grupo de usuario                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION CHECKGRUPO(_cGRUPO)    

	LOCAL LRET	:= .F.
	LOCAL I		:= 0
	LOCAL PERM	:= {}

	PSWORDER(2)

	IF PSWSEEK(CUSERNAME,.T.)
	
		PERM := PSWRET() // FUNCAO QUE RETORNA PERMISSOES DO USUARIO
	
	ENDIF

	FOR I := 1 TO LEN(PERM[1][10]) // POSICAO QUE INDICA GRUPOS A QUAL PERTENCE O USUARIO

		// GRUPOS DE USUARIOS QUE POSSUEM PERMISSAO DE ACESSO		

		IF PERM[1][10][I] $ ("000000/000015/") //000000 = Administradores 000015 = Fiscal
	    
	    	LRET := .T.
			EXIT

		ENDIF
		
	NEXT I

RETURN(LRET)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CHECKGRUPOº Autor ³ DOUGLAS CHAGAS     º Data ³  13/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RETORNA TRUE OU FALSE SE O USUARIO LOGADO PERTENCE A UM    º±±
±±º          ³ GRUPO INFORMADO                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
User Function CHECKGRUPO(_cGRUPO)

_lDESENV := .F.

_aGRUPOS := ALLGROUPS()

FOR I:=1 TO LEN(_aGRUPOS)
	
	IF ALLTRIM(UPPER(_aGRUPOS[I][1][2])) == ALLTRIM(UPPER(_cGRUPO))
		_cDESENV := ALLTRIM(_aGRUPOS[I][1][1])
	ENDIF
	
NEXT

_aGrpUSR := UsrRetGrp()
For _n:=1 to Len(_aGrpUSR)
	If ALLTRIM(_aGrpUSR[_n]) == _cDESENV
		_lDESENV := .T.
	Endif
Next

Return (_lDESENV)
*/      


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³   LOGALT º Autor ³CARLOS SILVA        º Data ³  30/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³FUNCAO RESPONSAVEL PELO ENVIOU DOS LOGS DAS ALTERACOES DOS  º±±
±±º          ³CAMPOS DOS PRODUTOS ATENDIMENTO DO CHAMADO 46259 27/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION LOGALT()

	cQuery := "SELECT B1_COD,B1_DESC,B1_UM,B1__PHOME,B1_PESBRU,B1_MSBLQL,B1_POSIPI,B1_PICMENT,B1_PICM,B1_IPI,B1_ORIGEM,B1__REDICM,B1_SITTRIB,B1__SITTRI,B1_TE,B1_GRTRIB,B1_WEB" + CRLF
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 WITH(NOLOCK)" + CRLF
	cQuery += "WHERE SB1.B1_COD ='"+SB1->B1_COD+"'" + CRLF   
	cQuery += "AND SB1.D_E_L_E_T_ <> '*' " + CRLF      
    cQuery += "GROUP BY B1_COD,B1_DESC,B1_UM,B1__PHOME,B1_PESBRU,B1_MSBLQL,B1_POSIPI,B1_PICMENT,B1_PICM,B1_IPI,B1_ORIGEM,B1__REDICM,B1_SITTRIB,B1__SITTRI,B1_TE,B1_GRTRIB,B1_WEB" + CRLF

	MemoWrite("ALOGALTS.SQL",cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"ALOGS", .F., .T.)  

	Count To nRec
	IF nRec == 0
	 	MSGSTOP("NAO EXISTEM DADOS PARA ALTERACAO!","ALOGS")
	 	ALOGS->(dbCloseArea())
        RETURN()
	ENDIF

    DBSELECTAREA("ALOGS")
	DBGOTOP() 
	
    LENVEMAIL()//ENVIOU DO EMAILS DA ALTERACAO		
	
	IF SELECT("ALOGS") > 0 //SE ESTIVER ABERTO FECHA 
	
	    ALOGS->(dbCloseArea())
	    
	ENDIF
		
RETURN()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³LENVEMAIL º Autor ³CARLOS SILVA        º Data ³  30/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ FUNCAO RESPONSAVEL PELO ENVIOU DOS EMAIL ATRAVES DA FUNCAO º±±
±±º          ³ U_ENVMAIL                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC FUNCTION LENVEMAIL() 

 	cMensl += "*****ANTES DA ALTERAÇÃO*****      " +ENTER 
    cMensl += "CODIGO DO PRODUTO ..............: " +ALOGS->B1_COD+ENTER
    cMensl += "DESCRICAO DO PRODUTO ...........: " +ALOGS->B1_DESC+ENTER  
    cMensl += "PRODUTO WEB ....................: " +ALOGS->B1_WEB+ENTER
    cMensl += "UNIDADE DE MEDIDA ..............: " +ALOGS->B1_UM+ENTER
    cMensl += "PRECO DE VENDA PHOME............: " +CVALTOCHAR(ALOGS->B1__PHOME)+ENTER
    cMensl += "PESO DO PRODUTO ................: " +CVALTOCHAR(ALOGS->B1_PESBRU)+ENTER  
    cMensl += "PRODUTO BLOQUEADO (1=SIM/2=NAO).: " +CVALTOCHAR(ALOGS->B1_MSBLQL)+ENTER   
	cMensl += "NCM ............................: " +CVALTOCHAR(ALOGS->B1_POSIPI)+ENTER
    cMensl += "MVA ............................: " +CVALTOCHAR(ALOGS->B1_PICMENT)+ENTER
    cMensl += "ICMS ...........................: " +CVALTOCHAR(ALOGS->B1_PICM)+ENTER
    cMensl += "IPI ............................: " +CVALTOCHAR(ALOGS->B1_IPI)+ENTER
    cMensl += "ORIGEM/CST......................: " +CVALTOCHAR(ALOGS->B1_ORIGEM)+ENTER
    cMensl += "REDUCAO DE ICMS ................: " +CVALTOCHAR(ALOGS->B1__REDICM)+ENTER
    cMensl += "SITUACAO TRIBUTARIA ............: " +CVALTOCHAR(ALOGS->B1_SITTRIB)+ENTER
    cMensl += "SIT.TRIB.REG ...................: " +CVALTOCHAR(ALOGS->B1__SITTRI)+ENTER
    cMensl += "TES ENTRADA ....................: " +CVALTOCHAR(ALOGS->B1_TE)+ENTER
    cMensl += "GRUPO TRIBUTARIA ...............: " +CVALTOCHAR(ALOGS->B1_GRTRIB)+ENTER+ENTER       
    cMensl += "*****DEPOIS DA ALTERAÇÃO*****     " +ENTER
	cMensl += "CODIGO DO PRODUTO ..............: " +M->B1_COD+ENTER
	cMensl += "DESCRICAO DO PRODUTO ...........: " +M->B1_DESC+ENTER 
    cMensl += "PRODUTO WEB ....................: " +M->B1_WEB+ENTER
	cMensl += "UNIDADE DE MEDIDA ..............: " +M->B1_UM+ENTER 
    cMensl += "PRECO DE VENDA PHOME ...........: " +CVALTOCHAR(M->B1__PHOME)+ENTER
    cMensl += "PESO DO PRODUTO ................: " +CVALTOCHAR(M->B1_PESBRU)+ENTER  
	cMensl += "PRODUTO BLOQUEADO (1=SIM/2=NAO).: " +CVALTOCHAR(M->B1_MSBLQL)+ENTER   
	cMensl += "NCM ............................: " +CVALTOCHAR(M->B1_POSIPI)+ENTER
    cMensl += "MVA ............................: " +CVALTOCHAR(M->B1_PICMENT)+ENTER
    cMensl += "ICMS ...........................: " +CVALTOCHAR(M->B1_PICM)+ENTER
    cMensl += "IPI ............................: " +CVALTOCHAR(M->B1_IPI)+ENTER
    cMensl += "ORIGEM/CST .....................: " +CVALTOCHAR(M->B1_ORIGEM)+ENTER
    cMensl += "REDUCAO DE ICMS ................: " +CVALTOCHAR(M->B1__REDICM)+ENTER
    cMensl += "SITUACAO TRIBUTARIA ............: " +CVALTOCHAR(M->B1_SITTRIB)+ENTER
    cMensl += "SIT.TRIB.REG....................: " +CVALTOCHAR(M->B1__SITTRI)+ENTER
    cMensl += "TES ENTRADA ....................: " +CVALTOCHAR(M->B1_TE)+ENTER
    cMensl += "GRUPO TRIBUTARIA ...............: " +CVALTOCHAR(M->B1_GRTRIB)+ENTER+ENTER	
	cMensl += "ALTERACAO DO PRODUTO.: "+Dtoc(dDataBase)+"-"+Time() +"-"+cDseman+ENTER
	cMensl += "NOME DO USUARIO: "+CUSERNAME+ENTER   
	cMensl += "ID DO USUARIO: "+__CUSERID+ENTER  		
	cMensl += "COMPUTADOR: "+getcomputerIP()+ENTER 
	cMensl += "IP: "+GetClientIP()+ENTER  
	cMensl += "AMBIENTE: "+GetEnvServer()+ENTER 
	cMensl += "FUNCAO: "+FUNNAME()+ENTER 
 	cMensl += "PROGRAMA: "+PROCNAME()+ENTER	
	cMensl += "HORARIO DO COMPUTADOR: "+GetRmtTime()+ENTER 			
	
	U_ENVMAIL('avisos@inforshop.net.br',cEmailAdm+";"+cEmallogs,'',cMensl,'Alteracao do Produto '+M->B1_COD+' em '+Dtoc(dDataBase)+ "-" +Time(),"")  
	
	IF (SB1->B1__PHOME >0 .AND. SB1->B1_WEB=="S") //PRODUTO PARA O VTEX/E-COMMERCE 
	
	   U_ENVMAIL('avisos@inforshop.net.br',cEmailAdm+";"+cEmalecomm,'',cMensl,'Alteracao do Produto '+M->B1_COD+' ECommerce em '+Dtoc(dDataBase)+ "-" +Time(),"")  
	   	
	ENDIF	 
    
RETURN()