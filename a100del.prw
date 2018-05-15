#INCLUDE "Protheus.ch"
#DEFINE ENTER Chr(13)+Chr(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA100DEL   บ Autor ณ Paulo Bindo        บ Data ณ  21/07/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ PONTO DE ENTRADA QUE VALIDA A EXCLUSAO DA NOTA DE ENTRADA  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function A100DEL()
Local lRet  := .T.
IF cEmpAnt <> "02" // nao executa na Inforlog (Jose Roberto)
	dbSelectArea("SD1")
	dbSetOrder(1)
	If !(dbSeek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE))
		Return(lRet)
	EndIf
	
	While !Eof().And. SD1->D1_FILIAL == xFilial('SD1') .And.;
		SD1->D1_DOC == SF1->F1_DOC .And.;
		SD1->D1_SERIE == SF1->F1_SERIE .And.;
		SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
		SD1->D1_LOJA == SF1->F1_LOJA
		
		//APAGA OS DADOS NA SZJ E ATUALIZA A SZI - PRECOS ESPECIAIS
		//GRAVASZJ(cZJFILIAL, cZJDOC, cZJSERIE, cZJPRODUTO, nZJQUANT, dZJDATA, cZJCLIFOR, cZJTIPO, cZJCODDESC, cINCEXC)
		If !Empty(SD1->D1__CODESP) .Or. SD1->D1__FSC $ "123"
			U_GRAVASZJ(SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_COD, SD1->D1_QUANT, SD1->D1_DTDIGIT, SD1->D1_FORNECE, "E", SD1->D1__CODESP, "E",SD1->D1__FSC)
		EndIf
		
		dbSelectArea("SD1")
		dbSkip()
	End
endif
Return(lRet)
