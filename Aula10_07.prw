#include "totvs.ch"
#include "ApWebSrv.ch"

user function WS_Client()
    local oWSCl := WSSA1_TRWS():New()
//rpcsetenv("99","01")
    OWSCL:CCCGC := ""
    OWSCL:CCCODIGO := "200000"
    OWSCL:CCLOJA := "01"
    OWSCL:OWSOSA1LINHA:CCCGC := "43814995000137"
    OWSCL:OWSOSA1LINHA:CCCODIGO:="300000"
    OWSCL:OWSOSA1LINHA:CCLoja:="01"
    OWSCL:OWSOSA1LINHA:CCNome:="cliente 300000 loja 01"
    OWSCL:OWSOSA1LINHA:CCPESSOA := 'J'
    OWSCL:OWSOSA1LINHA:CCEND := "logo ali"
    OWSCL:OWSOSA1LINHA:CCEST := "SP"
    OWSCL:OWSOSA1LINHA:CCMUN := "S SEBASTIAO"
    OWSCL:OWSOSA1LINHA:CCTIPO := "F"

    if oWSCl:GetSA1_PV()
        alert("Hora servidor:  + oWSCl:cGetSrvTimeResult")
    else
        alert("ERRO")
    endif

return



WSSTRUCT SA1LnSC6
    WSDATA produto      AS String
    WSDATA quantidade   AS String
    WSDATA preco        AS String
ENDWSSTRUCT

WSSTRUCT SA1LnSC5
    WSDATA numero  AS String
    WSDATA cdpgto  AS String
    WSDATA tipo    AS String
ENDWSSTRUCT

WSSTRUCT SA1Linha
    WSDATA cCodigo  AS String
    WSDATA cLoja    AS String
    WSDATA cNome    AS String
    WSDATA cPessoa  AS String
    WSDATA cTipo    AS String
    WSDATA cCGC     AS String
    WSDATA cEnd     AS String
    WSDATA cMun     AS String
    WSDATA cEst     AS String
    WSDATA pedido   AS SA1LnSC5
    WSDATA itens    AS Array OF SA1LnSC6

ENDWSSTRUCT

WSSERVICE SA1_TrWS DESCRIPTION "Webservice tabela de clientes SA1"
    WSDATA cResultado   AS String OPTIONAL
    WSDATA cCGC         AS String OPTIONAL
    WSDATA cCodigo      AS String OPTIONAL
    WSDATA cLoja        AS String OPTIONAL
    WSDATA aSA1Info     AS Array OF SA1Linha
    WSDATA oSA1Linha    AS SA1Linha

    WSMETHOD GetSA1Info DESCRIPTION "Obtem informações do cadastro de clientes"
    WSMETHOD PutSA1Info DESCRIPTION "Grava cliente"
    WSMETHOD GetSA1_PV DESCRIPTION "Obtem informações dos pedidos de venda dos clientes"
    WSMETHOD PutSA1_PV DESCRIPTION "Grava pedido"
ENDWSSERVICE

WSMETHOD PutSA1_PV WSSEND cResultado WSRECEIVE oSA1Linha WSSERVICE SA1_TrWS
return .T.


WSMETHOD PutSA1Info WSSEND cResultado WSRECEIVE oSA1Linha WSSERVICE SA1_TrWS
    RPCSetEnv("99", "01")
    
    local oModel := FWLoadModel("CRMA980")

    oModel:SetOperation(3)
    oModel:Activate()

    FWFldPut("A1_COD", oSA1Linha:cCodigo)
    //oModel:SetValue("A1_COD", oSA1Linha:cCodigo)
    FWFldPut("A1_LOJA", oSA1Linha:cLoja)
    FWFldPut("A1_NOME", oSA1Linha:cNome)
    FWFldPut("A1_NREDUZ", left(oSA1Linha:cNome, TamSX3("A1_NREDUZ")[1]))
    FWFldPut("A1_PESSOA", SELF:OSA1LINHA:CPESSOA)
    FWFldPut("A1_TIPO", SELF:OSA1LINHA:CTIPO)
    FWFldPut("A1_CGC", SELF:OSA1LINHA:CCGC)
    FWFldPut("A1_END", SELF:OSA1LINHA:CEND)
    FWFldPut("A1_MUN", SELF:OSA1LINHA:CMUN)
    FWFldPut("A1_EST", SELF:OSA1LINHA:CEST)

    If oModel:VldData() .and. oModel:CommitData()
        MsgInfo("Registro INCLUIDO!", "Atenção")
    Else
        MsgInfo(VarInfo("",oModel:GetErrorMessage()))
    EndIf       
     
    oModel:DeActivate()
    oModel:Destroy()
/*
    RecLock("SA1", .t.)
        sa1->A1_FILIAL := xfilial("SA1")
        sa1->A1_COD := oSA1Linha:cCodigo
        sa1->A1_LOJA := oSA1Linha:cLoja
        sa1->A1_NOME := oSA1Linha:cNome
    SA1->(msUnlock())
*/
return .T.

WSMETHOD GetSA1_PV WSSEND oSA1Linha WSRECEIVE cCodigo, cLoja WSSERVICE SA1_TrWS

    if Empty(cCodigo) .or. empty(cLoja)
        ::cResultado := "Código e/ou loja não informado"
    else
        SC5->(dbSetOrder(3))
        if sc5->(dbSeek(xFilial("SC5") + cCodigo + cLoja))
            OSA1LINHA:PEDIDO:numero := sc5->c5_num
            OSA1LINHA:PEDIDO:cdpgto := sc5->c5_condpag
            OSA1LINHA:PEDIDO:tipo := sc5->c5_tipo
            OSA1LINHA:PEDIDO:numero := sc5->c5_num
            OSA1LINHA:CCODIGO := sc5->c5_cliente
            OSA1LINHA:CLOJA := sc5->c5_lojacli

            SC6->(dbSetOrder(1))
            if sc6->(dbSeek(xFilial("SC6") + sc5->c5_num))
                aadd(OSA1LINHA:ITENS, WSClassNew("SA1LnSC6"))
                atail(OSA1LINHA:ITENS):produto    := sc6->c6_produto
                atail(OSA1LINHA:ITENS):quantidade := cvaltochar(sc6->c6_qtdven)
            endif
        else
            ::cResultado := "Nenhum pedido localizado"
        endif
    endif
return .T.

WSMETHOD GetSA1Info WSSEND aSA1Info WSRECEIVE cCGC, cCodigo, cLoja WSSERVICE SA1_TrWS
    local cCond := "%1 <> 1%"
    local cAlias := GetNextAlias()
    local oLinha

    default ::cCGC := ""
    default ::cCodigo := ""
    default ::cLoja := ""

    RPCSetEnv("99", "01")

    if empty(::cCGC + ::cCodigo + ::cLoja)
        cCond := "%1 = 1%"
    elseif !empty(::cCGC)
        cCond := "%A1_CGC = '" + ::cCGC + "'%"
    elseif !empty(::cCodigo) .and. !empty(::cLoja)
        cCond := "%A1_COD = '" + ::cCodigo + "' AND A1_LOJA = '" + ::cLoja + "'%"
    endif

    beginSQL Alias cAlias
        SELECT
            A1_COD,A1_LOJA,A1_NOME,A1_PESSOA,A1_TIPO,A1_CGC,A1_END,A1_MUN,A1_EST
        FROM
            %TABLE:SA1% SA1
        WHERE
            %Exp:cCond%
        ORDER BY
            A1_COD,A1_LOJA
    endSQL
    if (cAlias)->(eof())
        ::cResultado := "Nenhum cliente localizado..."
    else
        while (cAlias)->(!eof())
            aAdd(::aSA1Info, WSClassNew("SA1Linha"))

            oLinha := aTail(::aSA1Info)
            oLinha:cCodigo  := (cAlias)->A1_COD
            oLinha:cLoja    := (cAlias)->A1_LOJA
            oLinha:cNome    := (cAlias)->A1_NOME

            (cAlias)->(dbSkip())
        end
    endif
    (cAlias)->(dbCloseArea())
return .T.
