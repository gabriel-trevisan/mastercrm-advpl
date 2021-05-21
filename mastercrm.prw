#include "TOTVS.ch"
#include "Protheus.ch"
#include "parmtype.ch"

Class MasterCRM
	data cCookie
	data cUrlBase
	data oRestClient

	Method login()
	Method clientes()
	Method anexo()
	Method anexos()
	Method New() constructor
EndClass

Method New() Class MasterCRM
	::cUrlBase := 'https://app2.mastercrm.ws'
	::oRestClient := FWRest():New(::cUrlBase)
Return

/*/{Protheus.doc} MasterCRM::login
Classe para realizar o login na API do MasterCRM
@type method
@version 12.1.27
@author gabriel-trevisan
@since 20/05/2021
@param cUsername, character, email
@param cPassword, character, senha
@param cTenant, character, empresa
/*/
Method login(cUsername, cPassword, cTenant) Class MasterCRM

	Local cPath := "/api/login"
	Local cJson :=  '{"username":"'+cUsername+'","password":"'+cPassword+'","tenant":"'+cTenant+'"}'
	Local aHeaderStr := {}

	aAdd(aHeaderStr,"Content-Type: application/json" ) 
	::oRestClient:setPath(cPath)

	::oRestClient:SetPostParams(cJson)
	If ::oRestClient:Post(aHeaderStr)
		::cCookie := "Cookie: " + FwCutOff(strtran(::oRestClient:ORESPONSEH:AHEADERFIELDS[5][2], "; Path=/; HttpOnly", ""), .F.)
	Else
		return(::oRestClient:GetLastError())
	Endif

Return

/*/{Protheus.doc} MasterCRM::buscarCliente
Buscar cliente de acordo com o filtro passado por parâmetro.
@type method
@version 12.1.27 
@author gabriel-trevisan
@since 28/12/2020
@param cFiltro, character, o filtro é uma string, o padrão do filtro deve ser 
RestQuery. Existe um exemplo no inicio desse fonte
/*/
Method clientes(aHeaderStr) Class MasterCRM

	Local cPath := "/api/v1/integration/record"
	Local aHeaderStr := addCookieH(aHeaderStr, ::cCookie)
	Local oJSON   := NIL

	::oRestClient:setPath(cPath)
	
	If ::oRestClient:Get(aHeaderStr)
		FWJsonDeserialize(::oRestClient:GetResult(), @oJSON)
		return oJSON
	Else
		return(::oRestClient:GetLastError())
	Endif

Return

/*/{Protheus.doc} addCookieH
Função auxiliar para criar cabeçalho de string
@type function
@version  12.1.27
@author gabriel-trevisan
@since 30/12/2020
@param aHead, array, retorna array de string reformulado para API já com o Cookie
@return array, array de string
/*/
static function addCookieH(aHeaderStr, cCookie)
	Local aHead := { cCookie }
	Local nCont

	for nCont := 1 to Len(aHeaderStr) step 1
		Aadd(aHead, aHeaderStr[nCont])
	next nCont

return aHead

/*/{Protheus.doc} nameArqAnx
Função auxiliar para trazer nome arquivo do anexo
@type function
@version  12.1.27
@author gabriel-trevisan
@since 30/12/2020
@param aHead, array, retorna array de string reformulado para API já com o Cookie
@return array, array de string
/*/
static function nameArqAnx(aHeadField)
	Local cNameArq := ''

	cNameArq := strtran(aHeadField, 'attachment; filename="', '')
	cNameArq := strtran(cNameArq, '"', '')

return FwCutOff(cNameArq, .T.)

/*/{Protheus.doc} MasterCRM::anexo
Buscar anexo
@type method
@version 12.1.27 
@author gabriel-trevisan
@since 29/12/2020
@param cFiltro, character, o filtro é uma string, o padrão do filtro deve ser 
RestQuery. Existe um exemplo no inicio desse fonte
/*/
Method anexo(cIdCli, cIdAnexo) Class MasterCRM

	Local cPath := "/api/v10/customer/customers/"+cIdCli+"/attachments/"+cIdAnexo+"/file"
	Local aHeaderStr :=  addCookieH({}, ::cCookie)
	Local cNameArq := ""
	Local cResultR := ""

	::oRestClient:setPath(cPath)

	If ::oRestClient:Get(aHeaderStr)

		cNameArq := nameArqAnx(::oRestClient:ORESPONSEH:AHEADERFIELDS[6][2])
		cResultR := ::oRestClient:GetResult()

	Else
		return(::oRestClient:GetLastError())
	Endif

Return {cNameArq, cResultR}

/*/{Protheus.doc} MasterCRM::anexos
Buscar anexos
@type method
@version 12.1.27 
@author gabriel-trevisan
@since 29/12/2020
@param cFiltro, character, o filtro é uma string, o padrão do filtro deve ser 
RestQuery. Existe um exemplo no inicio desse fonte
/*/
Method anexos(cIdCli) Class MasterCRM

	Local cPath := "/api/v10/customer/customers/"+cIdCli+"/attachments"
	Local aHeaderStr :=  addCookieH({}, ::cCookie)
	Local oJson := NIL

	::oRestClient:setPath(cPath)

	If ::oRestClient:Get(aHeaderStr, "q={select->[id,description,size,userName,insertedAt]}")
		FWJsonDeserialize(::oRestClient:GetResult(), @oJSON)
	Else
		return(::oRestClient:GetLastError())
	Endif

	if oJson:count == 0
		Return {}
	endif

Return oJson:ITEMS 
