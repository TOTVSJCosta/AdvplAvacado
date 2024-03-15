#include "totvs.ch"
#include "FWMVCDEF.CH"
#include "fileIO.ch"


user function Aula1403()
    //Local oDlg      := TDialog():New()
    Local oBrw   := FWMBrowse():New(/*oDlg*/)

    oBrw:SetAlias("SC5")
    oBrw:SetDescription("Pedidos de Venda")
    oBrw:SetMenuDef("AdvplAdv")
    //oBrw:AddLegend("C5_TIPO == 'N'", 'GREEN')
    
    oBrw:Activate()
    //oDlg:Activate()
return

static function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title 'Incluir' Action 'VIEWDEF.AdvplAdv';
        OPERATION 3 ACCESS 0
    ADD OPTION aRet Title 'Alterar' Action 'VIEWDEF.AdvplAdv';
        OPERATION 4 ACCESS 0
    ADD OPTION aRet Title 'Visualizar' Action 'VIEWDEF.AdvplAdv';
        OPERATION 2 ACCESS 0
    
    ADD OPTION aRet Title 'Importar' Action 'U_ImpFile()';
        OPERATION 3 ACCESS 0

return aRet

user function ImpFIle(aParams)

    Default aParams := {"99", "01"}

    Local cFile
    Local lRet      := .T.
    //Local nHandle   := FT_FUse(cFile)
    //Local nHandle   := fOpen("C:\temp\x.txt", FO_READ)
    //Local aSize     := {}
    //Local cTxt      AS Character
    Local cLinha    AS Character
    Local oFile     AS Object

    /*isBlind()*/
    if Select("SX2") == 0 .and. valtype(aParams) == 'A' .and. len(aParams) >= 2
        RPCSetEnv(aParams[1], aParams[2])

        cFile  := GetMV("ES_CSVFILE")
        aFiles := {}
        aDir(cFile + "sa19901.csv", @aFiles)
        cFile += "sa19901.csv"
    else
        cFile := cGetFile("*.*", "Selecior arquivo",,,, GETF_LOCALHARD + GETF_NETWORKDRIVE)
    endif

    if !empty(cFile)
        oFile  := FWFileReader():New(cFile)

        if (oFile:Open())

            while oFile:hasLine()
                cLinha := oFile:GetLine()
                RotMVC(cLinha)
            end
            oFile:Close()
        else
        endif
    else
        msgAlert("Operação cancelada!")
    endif

/*
    aDir("C:\temp\x.txt",, @aSize)

    if nHandle == -1
        Alert(FError())
    else
        //cTxt := FReadStr(nHandle, aSize[1])

        FT_FGoTop()
        
        while !FT_FEOF()
            cLinha  := FT_FReadLn()
            
            /*RecLock("SA1", .F.)
                SA1->A1_NOME := upper(SA1->A1_NOME)
                SA1->A1_CEP := '99999999'
            SA1->(MsUnlock())

            FT_FSKIP()
        end
        FT_FUSE()
    endif
*/
    if(Select("SX2") == 0, RPCClearEnv(), nil)

return lRet

user function _MDLPV_PE()

    alert(varInfo("PIXB", PARAMIXB))

return .t.

Static Function ModelDef()

    Local oStruSC5  := FWFormStruct(1, "SC5")
    Local oStruSC6  := FWFormStruct(1, "SC6")
    Local oModel    := MPFormModel():New("MDLPV_PE",,, {|oModel| GravaPV(oModel)})

    oModel:AddFields("SC5MASTER",, oStruSC5)
    oModel:AddGrid("SC6DETAIL", "SC5MASTER", oStruSC6)

    oModel:SetRelation(;
        "SC6DETAIL",   ;
        {{"C6_FILIAL", "xFilial('SC6')"}, {"C6_NUM", "C5_NUM"}}, ;
        SC6->(IndexKey(1));
    )
    oModel:SetDescription("Pedidos de Venda")
    oModel:GetModel("SC5MASTER"):SetDescription("Pedidos de Venda")
    oModel:GetModel("SC6DETAIL"):SetDescription("Itens dos pedidos de venda")

Return oModel

static function ViewDef()

    Local oModel    := FWLoadModel("ADVPLADV") //ModelDef()
    Local oStruSC5  := FWFormStruct(2, "SC5")
    Local oStruSC6  := FWFormStruct(2, "SC6")
    Local oView     := FWFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_SC5", oStruSC5, "SC5MASTER")
    oView:AddGrid( "VIEW_SC6", oStruSC6, "SC6DETAIL")

    oView:CreateHorizontalBox("SUPERIOR", 40)
    oView:CreateHorizontalBox("INFERIOR", 60)

    oView:SetOwnerView("VIEW_SC5", "SUPERIOR")
    oView:SetOwnerView("VIEW_SC6", "INFERIOR")

return oView

static function GravaPV(oModel)

    //Local nOper := oModel:GetOperation()
    Local lRet  := .T.


    FWFormCommit(oModel)

return lRet

user function FakePrt()
    Local aArea     := GetArea()
    rpcsetenv("99", "01")
    Local aAreaSC5  := SC5->(GetArea())
    Local aAreaSC6  := SC6->(GetArea())    

    //FSQL()
    //RotAut()
    //RotMan()
    //RotMVC()
    U_ImpFIle({"99", "01"})

    RestArea(aArea)
    SC5->(RestArea(aAreaSC5))
    SC6->(RestArea(aAreaSC6))
    rpcclearenv()
return

static function FSQL()

    Local cTMPSA1 := GetNextAlias()
    //Local cQry    AS Character

    BEGINSQL ALIAS cTMPSA1
        COLUMN A1_DTCAD AS Date
        SELECT
            SA1.R_E_C_N_O_ RECNO,
            SA1.A1_DTCAD
        FROM
            %TABLE:SA1% SA1
        WHERE
            SA1.A1_FILIAL = %XFILIAL:SA1% AND SA1.%notDel%
    ENDSQL
/*
    cQry += " SELECT R_E_C_N_O_ RECNO, A1_DTCAD "
    cQry += " FROM " + RetSQLName("SA1") "
    cQry += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND D_E_L_E_T_ = ' ' "

    DBUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cQry), (cTMPSA1) , .F., .T.)
    TCSetField(cTMPSA1, "A1_DTCAD", 'D')
*/
    while (cTMPSA1)->(!EOF())
        SA1->(dbGoTo((cTMPSA1)->RECNO))
        
        RecLock("SA1", .F.)
            SA1->A1_NOME := upper(SA1->A1_NOME)
            SA1->A1_CEP := '99999999'
        SA1->(MsUnlock())

        (cTMPSA1)->(dbSkip())
    end
    (cTMPSA1)->(DBCloseArea())
    
return

static function RotAut()

    Local nItem     AS Numeric
    Local aSC5      := {}
    Local aSC6      := {}
    Local aItens    := {}

    //for
        aAdd(aSC5, {"C5_CLIENTE", "100000", NIL})
        aAdd(aSC5, {"C5_CONDPAG", "001", NIL})

        for nItem := 1 to 3
            aSC6 := {}

            AAdd(aSC6, {"C6_PRODUTO",   "00001",    NIL})
            AAdd(aSC6, {"C6_QTDVEN",    68 * nItem, NIL})
            AAdd(aSC6, {"C6_PRCVEN",    10,         NIL})
            AAdd(aSC6, {"C6_TES",       "501",      NIL})
            aAdd(aItens, aSC6)
        next nItem

        BEGIN TRANSACTION
            lMsErroAuto := .F.

            MsExecAuto({|x,y,z| MATA410(x,y,z)}, aSC5, aItens, MODEL_OPERATION_INSERT)

            if lMsErroAuto
            
                RollBackSX8()
                DisarmTransaction()
            else
                ConfirmSX8()
            endif

        END TRANSACTION
    //next
return

static function RotMan()

    Local cPV AS Character

    BEGIN TRANSACTION
        cPV := GetSX8Num("SC5", "C5_NUM")

        SC5->(dbSetOrder(1))
        
        if SC5->(dbSeek(xFilial("SC5") + cPV))
            msgAlert("pedido de venda num: " + cPv + " ja existe","erro PV")

            RollBackSX8()
            DisarmTransaction()
        else
            RecLock("SC5", .T.)
                SC5->C5_FILIAL  := XFILIAL("SC5")
                SC5->C5_NUM     := cPV
                SC5->C5_TIPO    := 'N'
                SC5->C5_CLIENTE := '200000'
                SC5->C5_LOJACLI := '01'
                SC5->C5_CLIENT  := '200000'
                SC5->C5_LOJAENT := '01'
                SC5->C5_TIPOCLI := 'F'
                SC5->C5_CONDPAG := '001'
            SC5->(MsUnlock())

            RecLock("SC6", .T.)
                SC6->C6_FILIAL  := XFILIAL("SC6")
                SC6->C6_ITEM    := '01'
                SC6->C6_PRODUTO := '00001'
                SC6->C6_UM      := 'PC'
                SC6->C6_QTDVEN  := 5
                SC6->C6_PRCVEN  := 6
                SC6->C6_VALOR   := 30
                SC6->C6_TES     := '501'
                SC6->C6_NUM     := cPV
            SC6->(MsUnlock())

            ConfirmSX8()

        endif

    END TRANSACTION
return

static function RotMVC(cLinha)

    Local aLinha := Separa(cLinha,';')
    Local lRet   := .T.
    Local cCod   := GetSX8Num("SA1", "A1_COD")
    Local oModel := FWLoadModel("CRMA980")

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    lRet := lRet .and. FWFldPut("A1_COD",       cCod)
    lRet := lRet .and. FWFldPut("A1_LOJA",       "01")
    lRet := lRet .and. FWFldPut("A1_NOME",      ALinha[1])
    lRet := lRet .and. FWFldPut("A1_PESSOA",    ALinha[2])
    lRet := lRet .and. FWFldPut("A1_NREDUZ",    ALinha[3])
    lRet := lRet .and. FWFldPut("A1_END",       ALinha[4])
    lRet := lRet .and. FWFldPut("A1_MUN",       ALinha[11])
    lRet := lRet .and. FWFldPut("A1_TIPO",      ALinha[6])
    lRet := lRet .and. FWFldPut("A1_EST",       ALinha[7])
    lRet := lRet .and. FWFldPut("A1_CGC",       ALinha[26])
    lRet := lRet .and. FWFldPut("A1_PAIS",      '105')
  
    lRet := lRet .and. (lRet := oModel:VldData())
    lRet := lRet .and. (lRet := oModel:CommitData())

    if !lRet
        RollBackSX8()
        Help(,,, "IMPSA1AUT", varInfo("erro MVC", oModel:GetErrorMessage()))
    else
        ConfirmSX8()
    endif
return lRet

User Function CRMA980()
    local oModel    := FWLoadModel("CRMA980")
    local xRet      := .T.
    local nOper     AS Numeric
    local cIDPE     := PARAMIXB[2]

    nOper := oModel:GetOperation()

    if cIDPE == "BUTTONBAR"
       xRet := {{'Importar clientes', 'SALVAR', {|| U_ImpFIle()}, 'Importar clientes de arq CSV'}}
    endif

return xRet

user function TTable()

    local aFields := {}
    local oTempTable := FWTemporaryTable():New("TTable")

    aAdd(aFields, {"NOME",    "C", 50, 0})
    aAdd(aFields, {"VALOR",   "N",  8, 2})
    aAdd(aFields, {"EMISSAO", "D",  8, 0})
    
    oTempTable:SetFields(aFields)
    oTempTable:Create()
    
    /*
        Aqui você faz as suas customizações, usando seu alias, por exemplo
        Alert( ALIAS->NOME_DO_CAMPO )
    */
    
    oTempTable:Delete()
return
