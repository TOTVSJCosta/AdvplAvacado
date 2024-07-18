#include "totvs.ch"
#include "FWMVCDef.ch"


user function Aula10_07()

	//rpcsetenv("99", "01")

	local oBrowse := FWmBrowse():New()

	oBrowse:SetAlias("ZZ1")
	oBrowse:SetDescription("Integrações")
	oBrowse:SetMenuDef("AULA10_07")
	oBrowse:DisableDetails()
	oBrowse:AddLegend("ZZ1_STATUS = 'H'", 'GREEN', "Habilitada")
	oBrowse:AddLegend("ZZ1_STATUS = 'D'", 'PINK', "Desabilitada")
	//oBrowse:SetFilterDefault("A2_TIPO $ if(__cUserID = '000000', 'FJX', 'FJ')")

	oBrowse:Activate()
return

static function MenuDef()
	local aMenu := {}

	ADD OPTION aMenu Title 'Incluir'    Action "ViewDef.AULA10_07" ;
		OPERATION MODEL_OPERATION_INSERT ACCESS 0

	ADD OPTION aMenu Title 'Alterar'    Action "ViewDef.AULA10_07" ;
		OPERATION MODEL_OPERATION_UPDATE ACCESS 0

	ADD OPTION aMenu Title 'Visualizar' Action "ViewDef.AULA10_07" ;
		OPERATION MODEL_OPERATION_VIEW ACCESS 0

	ADD OPTION aMenu Title 'Histórico'  Action 'U_Historico'       ;
		OPERATION MODEL_OPERATION_VIEW ACCESS 0
return aMenu

user function Historico()

return

static function ModelDef()
	local oStruZZ1  := FwFormStruct(1, "ZZ1")
	local oStruZZ2  := FwFormStruct(1, "ZZ2")
	local oModel    := MPFormModel():New("MD_ZZ1")

	oModel:AddFields("ZZ1MASTER", nil, oStruZZ1)
	oModel:SetPrimaryKey({"ZZ1_FILIAL", "ZZ1_ID"})

	oModel:AddGrid("ZZ2DETAIL", 'ZZ1MASTER', oStruZZ2)
	oModel:SetRelation('ZZ2DETAIL', {{'ZZ2_FILIAL', 'xFilial("ZZ2")'}, ;
		{'ZZ2_TASKID', 'ZZ1_ID'}}, ZZ2->(IndexKey(1)))

	oModel:GetModel('ZZ2DETAIL'):SetOptional(.T.)
	oModel:GetModel('ZZ2DETAIL'):SetOnlyView (.T.)
	//oModel:GetModel('ZZ2DETAIL'):SetOnlyQuery (.T.)

	oModel:SetDescription("Integrações")
	oModel:GetModel("ZZ1MASTER"):SetDescription("Central de Integrações")
return oModel

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author jcosta
    @since 10/07/2024
    @version 1.0
    @param nao utiliza
    @return oView, Object, Interface MVC para tabela ZZ1
/*/
Static Function ViewDef()
	local oView := FWFormView():New()
	local oStruZZ1 := FWFormStruct(2, "ZZ1")
	local oStruZZ2 := FWFormStruct(2, "ZZ2")
	local oModel := ModelDef()

	oView:SetModel(oModel)
	oView:AddField("VIEW_ZZ1", oStruZZ1, "ZZ1MASTER")

	oView:AddGrid('VIEW_ZZ2', oStruZZ2, 'ZZ2DETAIL' )

	oView:CreateHorizontalBox("BrwZZ1" , 40)
	oView:SetOwnerView("VIEW_ZZ1", "BrwZZ1")

	oView:CreateHorizontalBox('INFERIOR', 60)
	oView:SetOwnerView("VIEW_ZZ2", "INFERIOR")

	oView:EnableTitleView('VIEW_ZZ2', "Historico das execuções")
	oView:AddUserButton("Executar Integração", 'CLIPS', {|oView| ExecInt(oView)})
Return oView

static function ExecInt(oView)
	local cNomePE := allTrim(ZZ1->ZZ1_FUNCAO)
	local cURL := allTrim(ZZ1->ZZ1_URL)
    local oFile := FWFileReader():New(cURL)
	local oRest := FWRest():New(cURL)
	local lOk := .f.

	if ZZ1->ZZ1_STATUS = 'D'
		msgAlert("Integração está desabilitada!" + CRLF + "Não é possível executar", "Exec desabilitada")
	else
		if ExistBlock(cNomePE)
			ExecBlock(cNomePE,,, {oFile, oRest})
		endif
		do case
			case ZZ1->ZZ1_METODO = 'A'
				cURL := if(lOk := oFile:Open(), 'oFile:fullRead()', oFile:OERROLOG:MESSAGE)

			case ZZ1->ZZ1_METODO = 'G'
				cURL := decodeUTF8(if(lOk := oRest:Get(), oRest:GetResult(), oRest:GetLastError()))

			case ZZ1->ZZ1_METODO = 'P'
			case ZZ1->ZZ1_METODO = 'U'
			case ZZ1->ZZ1_METODO = 'D'
		end case
		if ExistBlock(cNomePE)
			lOk := ExecBlock(cNomePE,,, {lOk, cURL, oFile, oRest})
		endif
		GravaLog(lOk, cURL)
	endif
	oFile:Close()
	freeObj(oRest)
	freeObj(oFile)
return

user function IntVCEP()
	local cCEP
	local jVCEP

	if type("PARAMIXB[1]") = 'L'
		cCEP  := PARAMIXB[2]
		jVCEP := jsonObject():New()
		jVCEP:fromJSON(cCEP)

		if PARAMIXB[1] .and. !jVCEP:hasProperty("erro")
			FWFldPut("A1_END", jVCEP["logradouro"])
			FWFldPut("A1_EST", jVCEP["uf"])
			FWFldPut("A1_BAIRRO", jVCEP["bairro"])
			FWFldPut("A1_COD_MUN", substr(jVCEP["ibge"], 3))
			FWFldPut("A1_MUN", jVCEP["localidade"])
			FWFldPut("A1_IBGE", jVCEP["ibge"])
			FWFldPut("A1_COMPLEM", jVCEP["complemento"])
			FWFldPut("A1_DDD", jVCEP["ddd"])
		else
			PARAMIXB[1] := .f.
			PARAMIXB[2] := "CEP nao localizado!"
			Aviso("API ViaCEP", PARAMIXB[2])
		endif
		return PARAMIXB[1]
	elseif !FWIsInCallStack("U_SA1CEP")
		cCEP := FWInputBox("Insira o CEP a ser consultado")
	else
		cCEP := M->A1_CEP
	endif
	PARAMIXB[2]:SetPath('/' + cCEP + "/json")
return

static function GravaLog(lOK, cResult)
	local oModel := FWLoadModel("MVCZZ2")

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWFldPut("ZZ2_STATUS", if(lOK, 'S', 'E'))
	FWFldPut("ZZ2_DATAEX", Date())
	FWFldPut("ZZ2_HORAEX", Time())
	FWFldPut("ZZ2_TASKID", ZZ1->ZZ1_ID)
	FWFldPut("ZZ2_RESULT", cResult)

	if oModel:VldData() .and. oModel:CommitData()
		lOK := .T.
	else
		lOK := .F.
	endif
	If(lOK, nil, FWAlertError(VarInfo("Erro gravação do Historico", oModel:GetErrorMessage(),, .f.)))

    oModel:DeActivate()
/*
    RecLock("ZZ2", .t.)
        ZZ2->ZZ2_FILIAL := xFilial("ZZ2")
        ZZ2->ZZ2_ID 	:= GetSX8Num("ZZ2", "ZZ2_ID")
        ZZ2->ZZ2_STATUS := if(lOK, 'S', 'E')
        ZZ2->ZZ2_DATAEX := Date()
        ZZ2->ZZ2_HORAEX := Time()
        ZZ2->ZZ2_TASKID := ZZ1->ZZ1_ID
        ZZ2->ZZ2_RESULT := cResult
    ZZ2->(msUnlock())
*/
return

user function IntSB1()
    Processa({|| ArqCSV()}, "Importando produtos...") 
return PARAMIXB[1]

static function ArqCSV()
    local aLinha, nLinhas, aLinhas, nI

	if type("PARAMIXB[1]") = 'L' .and. PARAMIXB[1]
        SB1->(dbSetOrder(1))

		nLinhas := len(aLinhas := PARAMIXB[3]:getAllLines())

		ProcRegua(nLinhas)

		for nI := 1 to nLinhas
			aLinha := Separa(aLinhas[nI], ';')

			IncProc("Gravando produto " + aLinha[1] + "...")

			if sb1->(dbSeek(xFilial("SB1") + aLinha[1]))
				alert("duplicidade")
				GravaLog(.f., "duplicidade " + aLinha[1])
			else
				GravaSB1(aLinhas[nI], aLinha)
			endif
		next nI
	endif
return

static function GravaSB1(cLinha, aLinha)
    local oModel
    local cTipoGrv := GetNewPar("ES_B1TPGRV", 'AUTO')

    if cTipoGrv != "AUTO"
        recLock("SB1", .t.)
            SB1->B1_FILIAL := XFILIAL("SB1")
            SB1->B1_COD    := aLinha[1]
            SB1->B1_DESC    := aLinha[2]
            SB1->B1_TIPO    := aLinha[3]
            SB1->B1_UM    := aLinha[4]
            SB1->B1_LOCPAD    := aLinha[5]
            SB1->B1_GRUPO    := aLinha[6]
            SB1->B1_PRV1    := val(strTran(aLinha[7], ',', '.'))
            SB1->B1_ucalstd    := if(aLinha[8] $ '/', CtoD(aLinha[8]), StoD(aLinha[8]))
            SB1->B1_MSBLQL := '1'
        sb1->(msUnlock())
    else
        oModel := FWLoadModel("MATA010")

        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()

        FWFldPut("B1_COD", aLinha[1])
        FWFldPut("B1_DESC", aLinha[2])
        FWFldPut("B1_TIPO", aLinha[3])
        FWFldPut("B1_UM", aLinha[4])
        FWFldPut("B1_LOCPAD", aLinha[5])
        FWFldPut("B1_GRUPO", aLinha[6])
        FWFldPut("B1_PRV1", val(strTran(aLinha[7], ',', '.')))
        FWFldPut("B1_ucalstd", if(aLinha[8] $ '/', CtoD(aLinha[8]), StoD(aLinha[8])))

        if oModel:VldData() .and. oModel:CommitData()
            lOK := .T.
        else
            lOK := .F.
        endif

        If(lOK, nil, FWAlertError(VarInfo("Erro inclusão do produto", oModel:GetErrorMessage(),, .f.)))

        oModel:DeActivate()
    endif
    GravaLog(.t., cLinha)
return
static function WebEngine(oPanel)
	local oWebEng := TWebEngine():New(oPanel)

	oWebEng:navigate("youtube.com")
	oWebEng:Align := CONTROL_ALIGN_ALLCLIENT
Return

static function PainelLE(oPanel)

	local oSEdit :=  TSimpleEditor():New(,, oPanel,,, "[ cText ]")
	oSEdit:Align := CONTROL_ALIGN_ALLCLIENT

return

user function SA1CEP()
	cIntID := GetNewPar("ES_SA1VCEP", "001")

	ZZ1->(dbSetOrder(1))
	if ZZ1->(dbSeek(xFilial("ZZ1") + cIntID))
		ExecInt()
	else
		FWAlertWarning("Não foi possível executar a integração " + cIntID, "API VIA CEP")
	endif
return .t.

user function ITEM()
    local cIDPE := PARAMIXB[2]
    local xRet := .t.

    if cIDPE == "BUTTONBAR"
        xRet := {}
        aAdd(xRet, {"Importar produtos", 'LOK', {|| SB1Bt()}})
    endif
return xRet

static function SB1Bt()
	ZZ1->(dbSetOrder(5))
	if ZZ1->(dbSeek(xFilial("ZZ1") + "002"))
		ExecInt()
	else
		FWAlertWarning("Não foi possível executar a integração 002", "SB1 x CSV")
	endif
return .t.
