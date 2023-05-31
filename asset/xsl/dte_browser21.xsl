<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" 
	xmlns:sii="http://www.sii.cl/SiiDte"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:local="http://custodium.com/local" 
	xmlns:func="http://exslt.org/functions" 
	xmlns:str="http://exslt.org/strings"
	xmlns:exsl="http://exslt.org/common"

	xmlns:inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
	xmlns:cdn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" 
	xmlns:dbn="urn:oasis:names:specification:ubl:schema:xsd:DebitNote-2"
	xmlns:ret="urn:sunat:names:specification:ubl:peru:schema:xsd:Retention-1"
	xmlns:per="urn:sunat:names:specification:ubl:peru:schema:xsd:Perception-1"
	xmlns:gre="urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2"
	xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" 
	xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
	xmlns:ccts="urn:un:unece:uncefact:documentation:2" 
	xmlns:ds="http://www.w3.org/2000/09/xmldsig#" 
	xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" 
	xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2" 
	xmlns:sac="urn:sunat:names:specification:ubl:peru:schema:xsd:SunatAggregateComponents-1" 
	xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" 
	xmlns:smd="urn:sunat:names:specification:ubl:peru:schema:xsd:SummaryDocuments-1"
	xmlns:vdd="urn:sunat:names:specification:ubl:peru:schema:xsd:VoidedDocuments-1"
	xmlns:jadal="http://tempuri.org/"
	extension-element-prefixes=" sii local func str exsl cdn cac cbc ccts ds ext qdt sac udt ret per gre smd vdd"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"> 

	<xsl:param name="ca4xml" select="'no'"/>
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

	<xsl:variable name="dominio" select="/Document/@Domain"/>
	<xsl:variable name="FechaHora" select="/cdn:CreditNote/cbc:IssueDate | /dbn:DebitNote/cbc:IssueDate | /inv:Invoice/cbc:IssueDate | /ret:Retention/cbc:IssueDate | /per:Perception/cbc:IssueDate | /gre:DespatchAdvice/cbc:IssueDate"/>
	<xsl:variable name="Ano" select="substring($FechaHora,3,2)"/>
	<xsl:variable name="Ano-completo" select="substring($FechaHora, 1, 4)"/>
	<xsl:variable name="Mes" select="substring($FechaHora,6,2)"/>
	<xsl:variable name="Dia" select="substring($FechaHora,9,2)"/>
	
	<xsl:variable name="FechaHoraVencimiento" select="/cdn:CreditNote/cbc:DueDate | /dbn:DebitNote/cbc:DueDate | /inv:Invoice/cbc:DueDate | /ret:Retention/cbc:DueDate | /per:Perception/cbc:DueDate | /gre:DespatchAdvice/cbc:DueDate"/>
	<xsl:variable name="AnoVencimiento" select="substring($FechaHoraVencimiento,3,2)"/>
	<xsl:variable name="Ano-completoVencimiento" select="substring($FechaHoraVencimiento, 1, 4)"/>
	<xsl:variable name="MesVencimiento" select="substring($FechaHoraVencimiento,6,2)"/>
	<xsl:variable name="DiaVencimiento" select="substring($FechaHoraVencimiento,9,2)"/>

	<xsl:variable name="URL" select="concat('http://',$dominio, $Ano, $Mes, '.acepta.pe/')"/>
	<xsl:variable name="NroDocEmisor" select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /ret:Retention/cac:AgentParty/cac:PartyIdentification/cbc:ID |
										   /per:Perception/cac:AgentParty/cac:PartyIdentification/cbc:ID|
										   /gre:DespatchAdvice/cac:DespatchSupplierParty/cbc:CustomerAssignedAccountID"/> 
	<xsl:variable name="TipoDocEmisor" select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID | 
										       /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID | 
										       /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID"/>  
	<xsl:variable name="RazonSocialEmisor" select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName | 
										           /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName | 
										           /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>   
	<xsl:variable name="DireccionEmisor" select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
										         /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
										         /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>    
	
	<xsl:variable name="NroDocReceptor" select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID | 
										   /ret:Retention/cac:ReceiverParty/cac:PartyIdentification/cbc:ID |
										   /per:Perception/cac:ReceiverParty/cac:PartyIdentification/cbc:ID|
										   /gre:DespatchAdvice/cac:DespatchSupplierParty/cbc:CustomerAssignedAccountID"/> 
	<xsl:variable name="TipoDocReceptor" select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID | 
										   /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID | 
										   /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/@schemeID |
										   /gre:DespatchAdvice/cac:DespatchSupplierParty/cbc:CustomerAssignedAccountID/@schemeID"/>
	<xsl:variable name="RazonSocialReceptor" select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName | 
													 /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName | 
													 /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>   
	<xsl:variable name="DireccionReceptor" select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
												   /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
												   /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>    
	<!-- ========== DATOS DEL COMPROBANTE============ -->
	<xsl:variable name="Folio" select="//inv:Invoice/cbc:ID |
									   //cdn:CreditNote/cbc:ID |
									   //dbn:DebitNote/cbc:ID"/>

 
	<xsl:variable name="SerieNumero" select="/cdn:CreditNote/cbc:ID | /dbn:DebitNote/cbc:ID | /inv:Invoice/cbc:ID | gre:DespatchAdvice/cbc:ID"/>
	<xsl:variable name="Serie" select="substring($SerieNumero,1,4)"/>  
	<xsl:variable name="date" select="10000 * number(substring($FechaHora, 1, 4)) + 100 * number(substring($FechaHora, 6, 2)) + number(substring($FechaHora, 9, 2))"/>
 
	<xsl:variable name="FechaHoraCR" select="/cdn:CreditNote/cac:BillingReference/cac:CreditNoteDocumentReference/cbc:IssueDate | /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate |  /dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate"/>
	<xsl:variable name="Ano-completoCR" select="substring($FechaHoraCR, 1, 4)"/>
	<xsl:variable name="MesCR" select="substring($FechaHoraCR,6,2)"/>
	<xsl:variable name="DiaCR" select="substring($FechaHoraCR,9,2)"/>
	
	
	<xsl:variable name="NodDebRef" select="substring(/dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID,1,1)"/>
	<xsl:variable name="NodCreRef" select="substring(/cdn:CreditNote/cac:BillingReference/cac:CreditNoteDocumentReference/cbc:ID | /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID,1,1)"/>
	
	<xsl:variable name="SerieNumeroRef" select="/dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID |
												 /cdn:CreditNote/cac:BillingReference/cac:CreditNoteDocumentReference/cbc:ID |
												 /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID"/>
												 
	<xsl:variable name="TipoNotaRef" select="/dbn:DebitNote/cac:DiscrepancyResponse/cbc:ResponseCode | 
										  /cdn:CreditNote/cac:DiscrepancyResponse/cbc:ResponseCode"/>
	<xsl:variable name="MotivoNotaRef" select="/dbn:DebitNote/cac:DiscrepancyResponse/cbc:Description | 
										  /cdn:CreditNote/cac:DiscrepancyResponse/cbc:Description"/>
										   

	<xsl:variable name="GuiaRemision" select="/inv:Invoice/cac:DespatchDocumentReference/cbc:ID | 
										   /cdn:CreditNote/cac:DespatchDocumentReference/cbc:ID | 
										   /dbn:DebitNote/cac:DespatchDocumentReference/cbc:ID"/> 	
										   
	<xsl:variable name="OrdenCompra" select="/inv:Invoice/cac:OrderReference/cbc:ID | 
										   /cdn:CreditNote/cac:OrderReference/cbc:ID | 
										   /dbn:DebitNote/cac:OrderReference/cbc:ID"/> 
 	
	<xsl:variable name="Sucursal" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Sucursal"/>   
	 
	 
	 
	<xsl:variable name="Observacion" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Observacion"/>   
											
	<xsl:variable name="Turno" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Turno"/>   
											
	<xsl:variable name="Lado" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Lado"/>   
											
	<xsl:variable name="AtentidoPor" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:AtentidoPor"/>   
											
	<xsl:variable name="Condicion" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Condicion"/>   
											
	<xsl:variable name="Odometro" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Odometro"/>   
											
	<xsl:variable name="PendientePago" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:PendientePago"/> 

	<xsl:variable name="Scop" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Scop"/> 
											
	<xsl:variable name="Placa" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Placa"/> 
											
	<xsl:variable name="Pagina" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Pagina"/> 
											
	<xsl:variable name="Telefono" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono |
											/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono |
											/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono |
											/ret:Retention/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono |
											/per:Perception/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono |
											/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:Telefono"/> 
	   
	<xsl:variable name="FechaGen" select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension[3]/ext:ExtensionContent/jadal:AdditionalInformationCliente/jadal:FechaGeneracion"/>   
	<xsl:variable name="DiaGen" select="substring($FechaGen,1,2)"/>  
	<xsl:variable name="MesGen" select="substring($FechaGen,4,2)"/>  
	<xsl:variable name="AnioGen" select="substring($FechaGen,7,4)"/>  
	
	<xsl:variable name="FechaHoraEntrega" select="gre:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cac:TransitPeriod/cbc:StartDate"/>
	<xsl:variable name="AnoEntrega" select="substring($FechaHoraEntrega,3,2)"/>
	<xsl:variable name="Ano-completoEntrega" select="substring($FechaHoraEntrega, 1, 4)"/>
	<xsl:variable name="MesEntrega" select="substring($FechaHoraEntrega,6,2)"/>
	<xsl:variable name="DiaEntrega" select="substring($FechaHoraEntrega,9,2)"/>
	
	<!-- ========== TIPOS DE MODALIDAD DE TRANSPORTE - GUIA DE REMISI�N ============ -->
	<xsl:variable name="ModalidadTransporte">  
		<xsl:if test="gre:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cbc:TransportModeCode[.='01']">Transporte p�blico</xsl:if>
		<xsl:if test="gre:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cbc:TransportModeCode[.='02']">Transporte privado</xsl:if>
	</xsl:variable>
	<xsl:variable name="CodModalidadTransporte" select="gre:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cbc:TransportModeCode"/>
	
	<xsl:variable name="TipoDocumento" select="normalize-space(gre:DespatchAdvice/cac:Shipment/cac:ShipmentStage/cac:DriverPerson/cbc:ID/@schemeID)"/>
	<!-- ========== FECHA DE REFERENCIA ============ -->
	<xsl:variable name="FechaReferencia" select="/cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate |
												/cdn:CreditNote/cac:BillingReference/cac:CreditNoteDocumentReference/cbc:IssueDate |	
												/dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate"/>
	
	<xsl:variable name="FecRefer">
		<xsl:if test="$FechaReferencia[.!='']">
			<xsl:value-of select="concat(substring($FechaReferencia, 9, 2),'/',substring($FechaReferencia,6,2),'/',substring($FechaReferencia, 1, 4))"/>
		</xsl:if>
	</xsl:variable>
  	<xsl:variable name="TipoNota" >  
		<xsl:if test="/cdn:CreditNote/cac:AccountingSupplierParty/cbc:CustomerAssignedAccountID[.!='']">Abonado</xsl:if>
		<xsl:if test="/dbn:DebitNote/cac:AccountingSupplierParty/cbc:CustomerAssignedAccountID[.!='']">Acreditado</xsl:if>
	</xsl:variable>
 
	<!-- ========== MONEDA ============ -->
	<xsl:variable name="Moneda" >  
		<xsl:if test="/inv:Invoice/cbc:DocumentCurrencyCode = 'USD' or
					  /cdn:CreditNote/cbc:DocumentCurrencyCode = 'USD' or
					  /dbn:DebitNote/cbc:DocumentCurrencyCode = 'USD' or 
					  /ret:Retention/sac:SUNATRetentionDocumentReference/sac:SUNATRetentionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'USD' or
					  /per:Perception/sac:SUNATPerceptionDocumentReference/sac:SUNATPerceptionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'USD'">US$</xsl:if>
					  
		<xsl:if test="/inv:Invoice/cbc:DocumentCurrencyCode = 'PEN' or
					  /cdn:CreditNote/cbc:DocumentCurrencyCode = 'PEN' or
					  /dbn:DebitNote/cbc:DocumentCurrencyCode = 'PEN' or
					  /ret:Retention/sac:SUNATRetentionDocumentReference/sac:SUNATRetentionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'PEN' or
					  /per:Perception/sac:SUNATPerceptionDocumentReference/sac:SUNATPerceptionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'PEN'">S/</xsl:if>
	</xsl:variable>
	<xsl:variable name="MonedaLarga" >  
			<xsl:if test="/inv:Invoice/cbc:DocumentCurrencyCode = 'USD'  or
						/cdn:CreditNote/cbc:DocumentCurrencyCode = 'USD' or
						/dbn:DebitNote/cbc:DocumentCurrencyCode = 'USD'  or 
						/ret:Retention/sac:SUNATRetentionDocumentReference/sac:SUNATRetentionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'USD' or
						/per:Perception/sac:SUNATPerceptionDocumentReference/sac:SUNATPerceptionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'USD'">DOLAR</xsl:if>
			<xsl:if test="/inv:Invoice/cbc:DocumentCurrencyCode = 'PEN' or
						/cdn:CreditNote/cbc:DocumentCurrencyCode = 'PEN' or
						/dbn:DebitNote/cbc:DocumentCurrencyCode = 'PEN' or
						/ret:Retention/sac:SUNATRetentionDocumentReference/sac:SUNATRetentionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'PEN' or
						/per:Perception/sac:SUNATPerceptionDocumentReference/sac:SUNATPerceptionInformation/cac:ExchangeRate/cbc:TargetCurrencyCode = 'PEN'">SOL</xsl:if>
	</xsl:variable> 
  
		<!-- ========== TIPOS CPE ABV ============ -->
	<xsl:variable name="TpoCPE" >  
		<xsl:if test="/inv:Invoice/cbc:InvoiceTypeCode[.='03']">BOLETA DE VENTA ELECTR&#211;NICA</xsl:if>
		<xsl:if test="/inv:Invoice/cbc:InvoiceTypeCode[.='01']">FACTURA ELECTR&#211;NICA</xsl:if>
		<xsl:if test="/cdn:CreditNote/cbc:ID[.!='']">NOTA DE CR&#201;DITO  ELECTR&#211;NICA</xsl:if>
		<xsl:if test="/dbn:DebitNote/cbc:ID[.!='']">NOTA DE D&#201;BITO &#160; ELECTR&#211;NICA</xsl:if>
		<xsl:if test="/ret:Retention/cbc:ID[.!='']">COMPROBANTE DE RETENCI&#211;N ELECTR&#211;NICO</xsl:if>
		<xsl:if test="/per:Perception/cbc:ID[.!='']">COMPROBANTE DE PERCEPCI&#211;N ELECTR&#211;NICO</xsl:if>
		<xsl:if test="/gre:DespatchAdvice/cbc:ID[.!='']">GUIA DE REMISI&#211;N ELECTR&#211;NICA</xsl:if>
		<xsl:if test="/vdd:VoidedDocuments/cbc:ID[.!='']">RESUMEN DE BAJA</xsl:if>
		<xsl:if test="/smd:SummaryDocuments/cbc:ID[.!='']">RESUMEN DE COMPROBANTE</xsl:if>
	</xsl:variable>
	
	<!-- ========== TIPOS CPE REFERENCIA============ -->
	<xsl:variable name="TpoCPERef" >  
		<xsl:choose>
			<xsl:when test="$NodDebRef ='F' and /dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='01']">FACTURA ELECTR&#211;NICA</xsl:when>
			<xsl:when test="$NodDebRef ='B' and /dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='03']">BOLETA DE VENTA ELECTR&#211;NICA</xsl:when>
			<xsl:when test="$NodDebRef !='F' and /dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='01']">FACTURA</xsl:when>
			<xsl:when test="$NodDebRef !='B' and /dbn:DebitNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='03']">BOLETA DE VENTA</xsl:when>
			<xsl:when test="$NodCreRef ='F' and /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='01']">FACTURA ELECTR&#211;NICA</xsl:when>
			<xsl:when test="$NodCreRef ='B' and /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='03']">BOLETA DE VENTA ELECTR&#211;NICA</xsl:when>
			<xsl:when test="$NodCreRef !='F' and /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='01']">FACTURA</xsl:when>
			<xsl:when test="$NodCreRef !='B' and /cdn:CreditNote/cac:BillingReference/cac:InvoiceDocumentReference/cbc:DocumentTypeCode[.='03']">BOLETA DE VENTA</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<!-- ========== TIPOS CPE CODIGO============ -->
	<xsl:variable name="Tipo" >  
		<xsl:if test="/inv:Invoice/cbc:InvoiceTypeCode[.='03']">03</xsl:if>
		<xsl:if test="/inv:Invoice/cbc:InvoiceTypeCode[.='01']">01</xsl:if>
		<xsl:if test="/cdn:CreditNote/cbc:ID[.!='']">07</xsl:if>
		<xsl:if test="/dbn:DebitNote/cbc:ID[.!='']">08</xsl:if>
		<xsl:if test="/ret:Retention/cbc:ID[.!='']">20</xsl:if>
		<xsl:if test="/per:Perception/cbc:ID[.!='']">40</xsl:if>
		<xsl:if test="/gre:DespatchAdvice/cbc:ID[.!='']">09</xsl:if>
		<xsl:if test="/vdd:VoidedDocuments/cbc:ID[.!='']">RA</xsl:if>
		<xsl:if test="/smd:SummaryDocuments/cbc:ID[.!='']">RC</xsl:if>
	</xsl:variable>
	 
	<!-- ========== VARIABLES PARA TIMBRE ============ -->
	<xsl:variable name="ValorResumen" >  
		<xsl:for-each select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension |
							/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension |
							/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension |
							/ret:Retention/ext:UBLExtensions/ext:UBLExtension |
							/per:Perception/ext:UBLExtensions/ext:UBLExtension|
							/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension">
			<xsl:value-of select="ext:ExtensionContent/ds:Signature/ds:SignedInfo/ds:Reference/ds:DigestValue"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="ValorFirma" >  
		<xsl:for-each select="/inv:Invoice/ext:UBLExtensions/ext:UBLExtension |
							/cdn:CreditNote/ext:UBLExtensions/ext:UBLExtension |
							/dbn:DebitNote/ext:UBLExtensions/ext:UBLExtension |
							/ret:Retention/ext:UBLExtensions/ext:UBLExtension |
							/per:Perception/ext:UBLExtensions/ext:UBLExtension|
							/gre:DespatchAdvice/ext:UBLExtensions/ext:UBLExtension">
			<xsl:value-of select="ext:ExtensionContent/ds:Signature/ds:SignatureValue"/>
		</xsl:for-each>
	</xsl:variable>

	
	<!-- ========== RETENCI\D3N/PERCEPCI\D3N INI============ -->
	<!-- ========== MONTO DEL PAGO============ -->
	<xsl:variable name="TotalRetPago" >  
		<xsl:if test="/ret:Retention/cbc:ID[.!='']">
			<xsl:value-of select="/ret:Retention/sac:SUNATTotalPaid"/>
		</xsl:if>
		<xsl:if test="/per:Perception/cbc:ID[.!='']">
			<xsl:value-of select="/per:Perception/sac:SUNATTotalCashed"/>
		</xsl:if>
		
	</xsl:variable>
	<!-- ========== MONTO RETENIDO============ -->
	<xsl:variable name="TotalRetenido" >  
		<xsl:if test="/ret:Retention/cbc:ID[.!='']">
			<xsl:value-of select="/ret:Retention/cbc:TotalInvoiceAmount"/>
		</xsl:if>
		<xsl:if test="/per:Perception/cbc:ID[.!='']">
			<xsl:value-of select="/per:Perception/cbc:TotalInvoiceAmount"/>
		</xsl:if>
	</xsl:variable>	
	<!-- ========== RETENCI\D3N/PERCEPCI\D3N FIN============ -->
	
	<!-- ========== GRAVADAS============ -->
	<xsl:variable name="TotalGravadas">
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '1000'">
					<xsl:value-of select="cbc:TaxableAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>  
	<xsl:variable name="TotalInafectas"> 
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '9998'">
					<xsl:value-of select="cbc:TaxableAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="TotalExoneradas">
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '9997'">
					<xsl:value-of select="cbc:TaxableAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="TotalGratuitas">
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '9996'">
					<xsl:value-of select="cbc:TaxableAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="TotalComprobante" select="//inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount |
											      //cdn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount |
											      //dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:PayableAmount"/>
	<!-- ========== TOTAL DESCUENTO============ -->
	<xsl:variable name="TotalDesc" select="inv:Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount |
											    cdn:CreditNote/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount |
											    dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:AllowanceTotalAmount"/>
	<xsl:variable name="TotalDescuento">
			<xsl:choose>
				<xsl:when test="TotalDesc != ''">
					<xsl:value-of select="$TotalDesc"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
	</xsl:variable>
	<!-- ========== TOTAL IGV============ -->
	<xsl:variable name="TotalIGV">
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '1000'">
					<xsl:value-of select="cbc:TaxAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>  		 
	
	<xsl:variable name="TotalISC">
		<xsl:for-each select="inv:Invoice/cac:TaxTotal/cac:TaxSubtotal |
							  cdn:CreditNote/cac:TaxTotal/cac:TaxSubtotal |
					          dbn:DebitNote/cac:TaxTotal/cac:TaxSubtotal">
			<xsl:choose>
				<xsl:when test="cac:TaxCategory/cac:TaxScheme/cbc:ID = '2000'">
					<xsl:value-of select="cbc:TaxAmount"/>  
				</xsl:when>
				<xsl:otherwise>	
					<xsl:value-of select="0.00"/>
				</xsl:otherwise>
			</xsl:choose>  
		</xsl:for-each>
	</xsl:variable>  	
	<!-- ========== TotalOtroTributos ============ -->
	<xsl:variable name="TotalOtroTributos" >   
			<xsl:choose>							
				<xsl:when test="/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount[.!=''] |
										  /cdn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount[.!=''] |
										  /dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:TaxExclusiveAmount[.!='']">	
					<xsl:value-of select="/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount |
										  /cdn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount |
										  /dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:TaxExclusiveAmount"/>
				</xsl:when>
				<xsl:otherwise>	
					0.00
				</xsl:otherwise>
			</xsl:choose>
	</xsl:variable>	
	
	<!-- ========== TotalOtroCargos ============ -->
	<xsl:variable name="TotalOtroCargos" >   
			<xsl:choose>							
				<xsl:when test="/inv:Invoice/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount[.!=''] |
										  /cdn:CreditNote/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount[.!=''] |
										  /dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:ChargeTotalAmount[.!='']">	
					<xsl:value-of select="/inv:Invoice/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount |
										  /cdn:CreditNote/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount |
										  /dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:ChargeTotalAmount"/>
				</xsl:when>
				<xsl:otherwise>	
					0.00
				</xsl:otherwise>
			</xsl:choose>
	</xsl:variable>	
	
	   
	<xsl:variable name="LeyObservacion" select="inv:Invoice/cbc:Note[2] | cdn:CreditNote/cbc:Note[2] | dbn:DebitNote/cbc:Note[2]"/>
	<xsl:variable name="Vendedor" select="inv:Invoice/cbc:Note[3] | cdn:CreditNote/cbc:Note[3] | dbn:DebitNote/cbc:Note[3]"/>
	<xsl:variable name="FormaPago" select="inv:Invoice/cbc:Note[4] | cdn:CreditNote/cbc:Note[4] | dbn:DebitNote/cbc:Note[4]"/>
	<xsl:variable name="FechaVencimiento" select="inv:Invoice/cbc:DueDate | cdn:CreditNote/cbc:DueDate | dbn:DebitNote/cbc:DueDate"/>
	<xsl:variable name="Browser" select="inv:Invoice/cbc:Note[6] | cdn:CreditNote/cbc:Note[6] | dbn:DebitNote/cbc:Note[6]"/>
 
	<!-- ========== FIN VARIABLES PARA DETRACCION ============ -->


	<!--IMAGENES .....................................................................................................................-->
 
 
	<xsl:decimal-format name="cl" decimal-separator="," grouping-separator="."/>
	<xsl:decimal-format name="us" decimal-separator="." grouping-separator=","/>
	<xsl:param name="xsl.cedible" select="'false'"/>
	<xsl:param name="custodium.ca4web" select="true()"/>
	<xsl:param name="custodium.document.href" select="''"/>
	<xsl:param name="custodium.stylesheet.href" select="''"/>
	<xsl:param name="xsl.validacedible" select="'false'"/>
	 
	<xsl:template name="visualizacion-documento">
		<xsl:param name="con-cedible" select="false()"/>
		<xsl:param name="page-number" select="1"/>
		<fo:block>
			<xsl:if test="$page-number &gt; 1">
				<xsl:attribute name="page-break-before">always</xsl:attribute>
			</xsl:if>
			
			
			
			<xsl:choose>
				<xsl:when test="$Tipo ='RC'">			
					<!-- RESUMEN DE COMPROBANTE -->
					<fo:table>
						<fo:table-column column-width="1cm"/>
						<fo:table-column column-width="19cm"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:block font-size="5pt">&#160;</fo:block>
								</fo:table-cell>
								<fo:table-cell>
									<fo:block font-size="1cm">&#160;</fo:block>
									<fo:block font-size="7pt">Raz�n Social:&#160;<xsl:value-of select="smd:SummaryDocuments/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></fo:block>
									<fo:block font-size="3pt">&#160;</fo:block>
									<fo:block font-size="7pt">RUC:&#160;<xsl:value-of select="smd:SummaryDocuments/cac:AccountingSupplierParty/cbc:CustomerAssignedAccountID"/></fo:block>
									<fo:block font-size="3pt">&#160;</fo:block>
									<fo:block font-size="7pt">Fecha documentos informados:&#160;<xsl:value-of select="smd:SummaryDocuments/cbc:ReferenceDate"/></fo:block>
									<fo:block font-size="3pt">&#160;</fo:block>
									<fo:block font-size="7pt">Fecha de env�o Resumen:&#160;<xsl:value-of select="smd:SummaryDocuments/cbc:IssueDate"/></fo:block>
									<fo:block font-size="3pt">&#160;</fo:block>
								</fo:table-cell>
							</fo:table-row>
						</fo:table-body>
					</fo:table>
					<fo:table>
						<fo:table-column column-width="1cm"/>
						<fo:table-column column-width="17cm"/>
						<fo:table-body>
							<fo:table-row>
								<fo:table-cell>
									<fo:block font-size="7pt">&#160;</fo:block>
								</fo:table-cell>
								<xsl:choose>
									<xsl:when test="smd:SummaryDocuments/sac:SummaryDocumentsLine/cac:Status/cbc:ConditionCode[.='1'] |
													smd:SummaryDocuments/sac:SummaryDocumentsLine/cac:Status/cbc:ConditionCode[.='2'] |
													smd:SummaryDocuments/sac:SummaryDocumentsLine/cac:Status/cbc:ConditionCode[.='3']">
										<fo:table-cell>
											<fo:table border-style="solid" border-width="0.3mm">
												<fo:table-column column-width="1cm"/>
												<fo:table-column column-width="3cm"/>
												<fo:table-column column-width="3cm"/>
												<fo:table-column column-width="1.5cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
													<fo:table-body>
														<!-- ETIQUETAS DETALLE............................. -->	
														<fo:table-row font-size="6.5pt" text-align="center" font-weight="bold">	
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>N� l�nea</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Tipo CPE</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>CPE</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Total</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Grabado</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Exonerado</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Inafecto</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>IGV</fo:block>
															</fo:table-cell>
														</fo:table-row>		
														<xsl:for-each select="smd:SummaryDocuments/sac:SummaryDocumentsLine">	
															<fo:table-row font-size="6.5pt">
																<!--N� LINEA-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="left">
																					&#160;<xsl:value-of select="cbc:LineID"/>
																	</fo:block>
																</fo:table-cell>
																<!--TIPO CPE-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="cbc:DocumentTypeCode"/>
																	</fo:block>
																</fo:table-cell>
																<!--CODIGO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="cbc:ID"/>
																	</fo:block>
																</fo:table-cell>
																<!--MONTO TOTAL-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="right">
																					<xsl:value-of select="format-number(sac:TotalAmount, ',##0.00', 'us')"/>&#160;
																	</fo:block>
																</fo:table-cell>
																<!--MONTO GRABADO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='01']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																			<xsl:otherwise>
																				<fo:block>&#160;</fo:block>
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--MONTO EXONERADO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='02']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																			<xsl:otherwise>
																				<fo:block>&#160;</fo:block>
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--MONTO INAFECTO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='03']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																			<xsl:otherwise>
																				<fo:block>&#160;</fo:block>
																			</xsl:otherwise>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--IGV-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="cac:TaxTotal">
																		<xsl:choose>
																			<xsl:when test="cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID[.='1000']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:TaxAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
															</fo:table-row>
														</xsl:for-each>
													</fo:table-body>		
											</fo:table>	
										</fo:table-cell>
									</xsl:when>
									<xsl:otherwise>
										<fo:table-cell>
											<fo:table border-style="solid" border-width="0.3mm">
												<fo:table-column column-width="1cm"/>
												<fo:table-column column-width="1.5cm"/>
												<fo:table-column column-width="1.5cm"/>
												<fo:table-column column-width="2cm"/>
												<fo:table-column column-width="2cm"/>
												<fo:table-column column-width="2cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
												<fo:table-column column-width="2.5cm"/>
													<fo:table-body>
														<!-- ETIQUETAS DETALLE............................. -->	
														<fo:table-row font-size="6.5pt" text-align="center" font-weight="bold">	
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>N� l�nea</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>C�digo</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Serie</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Correlativo Inicial</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Correlativo Final</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Total</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Grabado</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Exonerado</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>Monto Inafecto</fo:block>
															</fo:table-cell>
															<fo:table-cell border-bottom-style="solid" border-right-style="solid">
																<fo:block>IGV</fo:block>
															</fo:table-cell>
														</fo:table-row>						
														<xsl:for-each select="smd:SummaryDocuments/sac:SummaryDocumentsLine">						
															<fo:table-row font-size="6.5pt">
																<!--N� LINEA-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="left">
																					&#160;<xsl:value-of select="cbc:LineID"/>
																	</fo:block>
																</fo:table-cell>
																<!--CODIGO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="cbc:DocumentTypeCode"/>
																	</fo:block>
																</fo:table-cell>
																<!--SERIE-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="sac:DocumentSerialID"/>
																	</fo:block>
																</fo:table-cell>
																<!--CORRELATIVO INICIAL-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="sac:StartDocumentNumberID"/>
																	</fo:block>
																</fo:table-cell>
																<!--CORRELATIVO FINAL-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="center">
																					&#160;<xsl:value-of select="sac:EndDocumentNumberID"/>
																	</fo:block>
																</fo:table-cell>
																<!--MONTO TOTAL-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<fo:block text-align="right">
																					<xsl:value-of select="format-number(sac:TotalAmount, ',##0.00', 'us')"/>&#160;
																	</fo:block>
																</fo:table-cell>
																<!--MONTO GRABADO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='01']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--MONTO EXONERADO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='02']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--MONTO INAFECTO-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="sac:BillingPayment">
																		<xsl:choose>
																			<xsl:when test="cbc:InstructionID[.='03']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:PaidAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
																<!--IGV-->
																<fo:table-cell border-right-style="solid" border-width="0.3mm">
																	<xsl:for-each select="cac:TaxTotal">
																		<xsl:choose>
																			<xsl:when test="cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:ID[.='1000']">
																				<fo:block text-align="right">
																								<xsl:value-of select="format-number(cbc:TaxAmount, ',##0.00', 'us')"/>&#160;
																				</fo:block>
																			</xsl:when>
																		</xsl:choose>
																	</xsl:for-each>
																</fo:table-cell>
															</fo:table-row>
														</xsl:for-each>
													</fo:table-body>		
											</fo:table>	
										</fo:table-cell>	
									</xsl:otherwise>
								</xsl:choose>
							</fo:table-row>	
						</fo:table-body>
					</fo:table>
				</xsl:when>
				 
				<xsl:when test="$Tipo ='RA'">			
<!-- ERMISOR ............................. -->
			<fo:table>
				<fo:table-column column-width="1cm"/>
				<fo:table-column column-width="19cm"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="5pt">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:block font-size="1cm">&#160;</fo:block>
							<fo:block font-size="7pt">Raz&#243;n Social:&#160;<xsl:value-of select="vdd:VoidedDocuments/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/></fo:block>
							<fo:block font-size="3pt">&#160;</fo:block>
							<fo:block font-size="7pt">RUC:&#160;<xsl:value-of select="vdd:VoidedDocuments/cac:AccountingSupplierParty/cbc:CustomerAssignedAccountID"/></fo:block>
							<fo:block font-size="3pt">&#160;</fo:block>
							<fo:block font-size="7pt">Fecha documentos informados:&#160;<xsl:value-of select="vdd:VoidedDocuments/cbc:ReferenceDate"/></fo:block>
							<fo:block font-size="3pt">&#160;</fo:block>
							<fo:block font-size="7pt">Fecha de env&#237;o Comunicaci&#243;n de baja:&#160;<xsl:value-of select="vdd:VoidedDocuments/cbc:IssueDate"/></fo:block>
							<fo:block font-size="3pt">&#160;</fo:block>
						</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
			<fo:table>
				<fo:table-column column-width="18cm"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="7pt">&#160;</fo:block>
						</fo:table-cell>	
					</fo:table-row>	
				</fo:table-body>
			</fo:table>
			<fo:table>
				<fo:table-column column-width="1cm"/>
				<fo:table-column column-width="17cm"/>
				<fo:table-body>
					<fo:table-row>
						<fo:table-cell>
							<fo:block font-size="7pt">&#160;</fo:block>
						</fo:table-cell>
						<fo:table-cell>
							<fo:table border-style="solid" border-width="0.3mm">
								<fo:table-column column-width="1cm"/>
								<fo:table-column column-width="1.5cm"/>
								<fo:table-column column-width="1.5cm"/>
								<fo:table-column column-width="2cm"/>
								<fo:table-column column-width="13cm"/>
									<fo:table-body>
										<!-- ETIQUETAS DETALLE............................. -->	
										<fo:table-row font-size="6.5pt" text-align="center" font-weight="bold">	
											<fo:table-cell border-bottom-style="solid" border-right-style="solid">
												<fo:block>N&#176; l&#237;nea</fo:block>
											</fo:table-cell>
											<fo:table-cell border-bottom-style="solid" border-right-style="solid">
												<fo:block>C&#243;digo</fo:block>
											</fo:table-cell>
											<fo:table-cell border-bottom-style="solid" border-right-style="solid">
												<fo:block>Serie</fo:block>
											</fo:table-cell>
											<fo:table-cell border-bottom-style="solid" border-right-style="solid">
												<fo:block>N&#250;mero</fo:block>
											</fo:table-cell>
											<fo:table-cell border-bottom-style="solid" border-right-style="solid">
												<fo:block>Motivo de baja</fo:block>
											</fo:table-cell>
										</fo:table-row>						
										<xsl:for-each select="vdd:VoidedDocuments/sac:VoidedDocumentsLine">						
											<fo:table-row font-size="6.5pt">
												<!--N� LINEA-->
												<fo:table-cell border-right-style="solid" border-width="0.3mm">
													<fo:block text-align="left">
																	&#160;<xsl:value-of select="cbc:LineID"/>
													</fo:block>
												</fo:table-cell>
												<!--CODIGO-->
												<fo:table-cell border-right-style="solid" border-width="0.3mm">
													<fo:block text-align="center">
																	&#160;<xsl:value-of select="cbc:DocumentTypeCode"/>
													</fo:block>
												</fo:table-cell>
												<!--SERIE-->
												<fo:table-cell border-right-style="solid" border-width="0.3mm">
													<fo:block text-align="center">
																	&#160;<xsl:value-of select="sac:DocumentSerialID"/>
													</fo:block>
												</fo:table-cell>
												<!--NUMERO-->
												<fo:table-cell border-right-style="solid" border-width="0.3mm">
													<fo:block text-align="center">
																	&#160;<xsl:value-of select="sac:DocumentNumberID"/>
													</fo:block>
												</fo:table-cell>
												<!--MOTIVO-->
												<fo:table-cell border-right-style="solid" border-width="0.3mm">
													<fo:block text-align="left">
																	&#160;<xsl:value-of select="sac:VoidReasonDescription"/>
													</fo:block>
												</fo:table-cell>
											</fo:table-row>
										</xsl:for-each>
									</fo:table-body>		
							</fo:table>	
						</fo:table-cell>	
					</fo:table-row>	
				</fo:table-body>
			</fo:table>
				</xsl:when>
				 
				 
				<xsl:otherwise> <!-- FAC / BOL / NC / ND --> 
				
				
					<!-- FA,BV,NC,ND --> 
								
								<fo:table>
									<fo:table-column column-width="1cm"/>
									<fo:table-column column-width="19.0cm"/> 
									<fo:table-body>
										<fo:table-row>
											<fo:table-cell>
												<fo:block font-size="5pt">&#160;</fo:block>
											</fo:table-cell> 
											<fo:table-cell>
											<!-- INICIO TABLA PRINCIPAL -->
											<!-- CABECERA -->
												<fo:table> 
													<fo:table-column column-width="5.0cm"/>
													<fo:table-column column-width="6.1cm"/>
													<fo:table-column column-width="0.1cm"/>
													<fo:table-column column-width="7.8cm"/>
													<fo:table-body>
														<fo:table-row>   
															<fo:table-cell>
																<fo:block font-size="18pt">&#160;</fo:block> 
														 
															</fo:table-cell>	

															<fo:table-cell>
																<fo:block font-size="18pt">&#160;</fo:block> 
																<fo:block font-size="7pt"  font-weight="bold">
																	<xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																	 /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																	 /dbn:DebitNote/cac:AccountingSupplierPartyDespatchSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																	 /ret:Retention/cac:AgentParty/cac:PartyLegalEntity/cbc:RegistrationName |
																	 /per:Perception/cac:AgentParty/cac:PartyLegalEntity/cbc:RegistrationName |
																	 /gre:DespatchAdvice/cac:DespatchSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
																</fo:block>
																<fo:block font-size="8pt">
																Direcci�n: 
																<xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>	
																			<xsl:if test="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District"/>
																			</xsl:if>			   
																			<xsl:if test="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
																			</xsl:if>							
																			<xsl:if test="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /cdn:CreditNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /dbn:DebitNote/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity"/>
																			</xsl:if>	
																</fo:block>
																<fo:block font-size="8pt">
																Estaci�n:  
																	<xsl:value-of select="$Sucursal"/>
																</fo:block>
																 
																<fo:block font-size="8pt">Tel�fono: <xsl:value-of select="$Telefono"/></fo:block>
																<fo:block font-size="8pt">P�gina Web: <xsl:value-of select="$Pagina"/></fo:block>
																<fo:block font-size="5pt">&#160;</fo:block> 
															</fo:table-cell>		
															<fo:table-cell>
																<fo:block font-size="18pt">&#160;</fo:block>  
															</fo:table-cell>	
															<fo:table-cell>
																<fo:block font-size="8pt">&#160;</fo:block> 
																<fo:block border-style="solid" border-width="0.3mm" border-color="black" space-before="5mm">
																	<fo:block font-size="3pt">&#160;</fo:block>
																	<fo:block font-weight="bold" color="black" text-align="center" font-size="12pt">
																		R.U.C. N� <xsl:value-of select="$NroDocEmisor"/>
																	</fo:block>
																	<fo:block font-size="3pt">&#160;</fo:block>
																	<fo:block font-weight="bold" text-align="center" border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" border-color="black">
																		<fo:block font-size="3pt">&#160;</fo:block>
																		<fo:block font-size="12pt"><xsl:value-of select="$TpoCPE"/></fo:block>
																		<fo:block font-size="3pt">&#160;</fo:block>
																		
																	</fo:block>
																	<fo:block font-size="3pt">&#160;</fo:block>
																	<xsl:choose>
																		<xsl:when test="/inv:Invoice/cbc:ID[.!='']">
																			<fo:block font-weight="bold" color="black" text-align="center" font-size="12pt">
																				<xsl:value-of select="substring-before(/inv:Invoice/cbc:ID, '-')"/>&#160;
																				<xsl:value-of select="concat('N� ', substring-after(/inv:Invoice/cbc:ID, '-'))"/>
																			</fo:block>
																		</xsl:when>
																		<xsl:when test="/cdn:CreditNote/cbc:ID[.!='']">
																			<fo:block font-weight="bold" color="black" text-align="center" font-size="12pt">
																				<xsl:value-of select="substring-before(/cdn:CreditNote/cbc:ID, '-')"/>&#160;
																				<xsl:value-of select="concat('N� ', substring-after(/cdn:CreditNote/cbc:ID, '-'))"/>
																			</fo:block>
																		</xsl:when>
																		<xsl:when test="/dbn:DebitNote/cbc:ID">
																			<fo:block font-weight="bold" color="black" text-align="center" font-size="12pt">
																				<xsl:value-of select="substring-before(/dbn:DebitNote/cbc:ID, '-')"/>&#160;
																				<xsl:value-of select="concat('N� ', substring-after(/dbn:DebitNote/cbc:ID, '-'))"/>
																			</fo:block>
																		</xsl:when>
																		<xsl:when test="/gre:DespatchAdvice/cbc:ID[.!='']">
																			<fo:block font-weight="bold" color="black" text-align="center" font-size="12pt">
																				<xsl:value-of select="substring-before(/gre:DespatchAdvice/cbc:ID, '-')"/>&#160;
																				<xsl:value-of select="concat('N� ', substring-after(/gre:DespatchAdvice/cbc:ID, '-'))"/>
																			</fo:block>
																		</xsl:when>
																	</xsl:choose>
																	<fo:block font-size="3pt">&#160;</fo:block>
																</fo:block>
																<fo:block font-size="6pt">&#160;</fo:block> 
															</fo:table-cell>	 
															
														</fo:table-row>
													</fo:table-body>
												</fo:table>
												<fo:block font-size="5pt">&#160;</fo:block>
												<!-- DATOS DEL RECEPTOR  -->
												<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
													<fo:table-column column-width="14.5cm"/>
													<fo:table-column column-width="0.5cm"/>
													<fo:table-column column-width="4.0cm"/>
													<fo:table-body>
													<fo:table-row>
														  
														<fo:table-cell>
													 
															<fo:table> 
																<fo:table-column column-width="2.0cm"/> 
																<fo:table-column column-width="12.0cm"/> 
																<fo:table-body>
																	<fo:table-row> 
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block><fo:block font-size="7pt">&#160;SE�OR(ES)&#160;</fo:block></fo:table-cell>  
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block><fo:block font-size="7pt">:&#160;
																						<xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																						 /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																						 /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName |
																						 /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cbc:RegistrationName |
																						 /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cbc:RegistrationName |
																						 /gre:DespatchAdvice/cac:DeliveryCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
																		</fo:block></fo:table-cell>  
																	</fo:table-row> 
																	<fo:table-row> 
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block><fo:block font-size="7pt">&#160;DIRECCI�N&#160;</fo:block></fo:table-cell>  
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block>
																		<fo:block font-size="7pt">:&#160;
																			<xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName | 
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>	
																			<xsl:if test="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:District"/>
																			</xsl:if>			   
																			<xsl:if test="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
																			</xsl:if>							
																			<xsl:if test="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!=''] or
																								  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity[.!='']">
																				&#160;<xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /cdn:CreditNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /dbn:DebitNote/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /ret:Retention/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity | 
																									  /per:Perception/cac:ReceiverParty/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CountrySubentity"/>
																			</xsl:if>	 
																		</fo:block>
																		<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>  
																	</fo:table-row> 
																</fo:table-body>
															</fo:table>
													 
														</fo:table-cell>				 
														<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block>
														</fo:table-cell> 
														 
														<fo:table-cell>  
															<fo:table> 
																<fo:table-column column-width="2.0cm"/> 
																<fo:table-column column-width="2.0cm"/> 
																<fo:table-body>
																	<fo:table-row> 
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block><fo:block font-size="7pt">&#160;
																			<xsl:choose>
																				<xsl:when test="string-length($NroDocReceptor) = 11">
																					RUC
																				</xsl:when> 
																				<xsl:otherwise>
																					DNI
																				</xsl:otherwise>
																			</xsl:choose>  
																		</fo:block></fo:table-cell>  
																		<fo:table-cell><fo:block font-size="5pt">&#160;</fo:block><fo:block font-size="7pt">:&#160;<xsl:value-of select="$NroDocReceptor"/></fo:block>
																		<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>  
																	</fo:table-row>
																</fo:table-body>
															</fo:table> 
														</fo:table-cell>	
														
													</fo:table-row>
												</fo:table-body>
												</fo:table>
												
												<fo:block font-size="5pt">&#160;</fo:block>
 
											
												<xsl:choose>
													<xsl:when test="$Tipo = '01' or $Tipo = '03'">		
													 
														<!-- DATOS DEL GENERALES -->
															<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
																<fo:table-column column-width="3.5cm"/>
																<fo:table-column column-width="4.0cm"/>
																<fo:table-column column-width="3.5cm"/>
																<fo:table-column column-width="2.0cm"/>
																<fo:table-column column-width="3.0cm"/>
																<fo:table-column column-width="3.0cm"/> 
																<fo:table-body>
																	<fo:table-row> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">FECHA DE EMISI�N</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">FECHA DE VENCIMIENTO</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>  
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">N. GU�A DE REMISI�N</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell >  
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">MONEDA</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>   
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">N. PEDIDO</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">SCOP</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																	</fo:table-row>
																	
																	<fo:table-row> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$FechaHora"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$FechaHoraVencimiento"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>   
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$GuiaRemision"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell >  
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$MonedaLarga"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>   
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$OrdenCompra"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$Scop"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																	</fo:table-row>
																</fo:table-body>
															</fo:table>
													 
													</xsl:when>
													<xsl:when test="$Tipo = '07' or $Tipo = '08'">		
												 
														<!-- DATOS DEL GENERALES -->
															<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
																<fo:table-column column-width="6cm"/>
																<fo:table-column column-width="6cm"/>
																<fo:table-column column-width="7cm"/>  
																<fo:table-body>
																	<fo:table-row> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">TIPO DOC REF</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">DOC REF</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>  
																		<fo:table-cell border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">TIPO&#160;<xsl:value-of select="$TpoCPE"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell >   
																	</fo:table-row>
																	
																	<fo:table-row> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$TpoCPERef"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell> 
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$SerieNumeroRef"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>   
																		<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$TipoNotaRef"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell >  
																	</fo:table-row>
																	
																	<fo:table-row> 
																		<fo:table-cell number-columns-spanned="3" border-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" color="#FFFFFF" text-align="center">MOTIVO</fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>   
																	</fo:table-row>
																	 
																	<fo:table-row> 
																		<fo:table-cell number-columns-spanned="3" border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:block font-size="3pt">&#160;</fo:block>
																			<fo:block font-size="8pt" text-align="center">&#160;<xsl:value-of select="$MotivoNotaRef"/></fo:block>
																			<fo:block font-size="3pt">&#160;</fo:block>
																		</fo:table-cell>  
																	</fo:table-row>
																</fo:table-body>
															</fo:table>
												 
													</xsl:when>  
												</xsl:choose>
																				


												<fo:block font-size="5pt">&#160;</fo:block>  
												<!-- DETALLES -->
												<fo:table>
													<fo:table-column column-width="20cm"/>   
													<fo:table-body>  
														<fo:table-row>
															<fo:table-cell>  
																<fo:block>
																	<fo:table>  
																		<fo:table-column column-width="1.8cm"/> <!-- CANTIDAD --> 
																		<fo:table-column column-width="1.5cm"/> <!-- CODIGO --> 
																		<fo:table-column column-width="1.2cm"/> <!-- UNIDAD DE  MEDIDA -->
																		<fo:table-column column-width="6.5cm"/> <!-- DESCRIPCION --> 
																		<fo:table-column column-width="3.0cm"/> <!-- VALOR UNITARIO --> 
																		<fo:table-column column-width="3.0cm"/> <!-- PRECIO UNITARIO -->  
																		<fo:table-column column-width="2.0cm"/> <!-- IMPORTE -->  
																		<fo:table-column column-width="0.01cm"/>		 
																		<fo:table-body>
																			<!-- ETIQUETAS DETALLE............................. -->	
																	 
																			<fo:table-row font-size="6.5pt" text-align="center" font-weight="bold">		 									
																				
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF" >CANTIDAD</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>
																				
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF" >C�DIGO</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>

																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF">U.M</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell> 
																				
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF">DESCRIPCI�N</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell > 
																				 
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF">VALOR UNITARIO</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>  
																				
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF">PRECIO UNITARIO</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>
																				
																				<fo:table-cell border-top-style="solid" border-bottom-style="solid" border-right-style="solid" border-left-style="solid" border-width="0.3mm" background-color="#1A344A" border-color="black">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="8pt" color="#FFFFFF">IMPORTE</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>
																				
																				<fo:table-cell height="8cm" number-rows-spanned="{count(/inv:Invoice/cac:InvoiceLine |
																										  /cdn:CreditNote/cac:CreditNoteLine |
																										  /dbn:DebitNote/cac:DebitNoteLine) + 1}">
																					<fo:block/>
																				</fo:table-cell>
																			</fo:table-row>	 
																			
																			<xsl:for-each select="/inv:Invoice/cac:InvoiceLine |
																								  /cdn:CreditNote/cac:CreditNoteLine |
																								  /dbn:DebitNote/cac:DebitNoteLine |
																								  /ret:Retention/sac:SUNATRetentionDocumentReference |
																								  /per:Perception/sac:SUNATPerceptionDocumentReference">		
																				 <xsl:variable name="unimed" select="cbc:InvoicedQuantity/@unitCode"/>  
																				<fo:table-row font-size="6.5pt">	
																				
																					<!-- CANTIDAD -->
																					<fo:table-cell border-left-style="solid" border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="right">
																							<xsl:call-template name="NaN">
																								<xsl:with-param name="number" select="format-number(cbc:CreditedQuantity |
																																	  dbn:DebitedQuantity |
																																	  cbc:InvoicedQuantity, ',##0.000', 'us')"/>
																							</xsl:call-template>&#160;
																						</fo:block>
																					</fo:table-cell>
																					
																					<!-- C�digo -->
																					<fo:table-cell border-left-style="solid" border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="center">
																							<xsl:value-of select="cac:Item/cac:SellersItemIdentification/cbc:ID"/>
																						</fo:block>
																					</fo:table-cell>	
																					
																					<!-- Unidad de medida -->
																					<fo:table-cell border-left-style="solid" border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="center">
																							<xsl:value-of select="$unimed"/>
																						</fo:block>
																					</fo:table-cell>	 
																					
																					<!--DESCRIPCION PRODUCTO -->
																					<fo:table-cell border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																							<xsl:for-each select="cac:Item/cbc:Description">
																								<fo:block text-align="left">
																										&#160;<xsl:call-template name="divide_en_lineas">
																												<xsl:with-param name="val" select="."/>
																												<xsl:with-param name="c1" select="'^'"/>
																											</xsl:call-template>
																								</fo:block>
																							</xsl:for-each>
																							<xsl:for-each select="cac:Item/cbc:AdditionalInformation">
																								<fo:block text-align="left" font-size="6pt">
																										&#160;<xsl:call-template name="divide_en_lineas">
																											<xsl:with-param name="val" select="."/>
																											<xsl:with-param name="c1" select="'^'"/>
																										</xsl:call-template>
																								</fo:block>
																							</xsl:for-each>
																					
																					</fo:table-cell>
																					 
																					<!-- VALOR UNITARIO  -->
																					<fo:table-cell border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="right">
																							<xsl:call-template name="NaN">
																								<xsl:with-param name="number" select="format-number(cac:Price/cbc:PriceAmount, ',##0.00', 'us')"/>
																							</xsl:call-template> &#160;
																						</fo:block>
																					</fo:table-cell>	 
																					
																					<!-- VALOR UNITARIO  -->
																					<fo:table-cell border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="right">
																							<xsl:call-template name="NaN">
																								<xsl:with-param name="number" select="format-number(cac:PricingReference/cac:AlternativeConditionPrice/cbc:PriceAmount, ',##0.00', 'us')"/>
																							</xsl:call-template> &#160;
																						</fo:block>
																					</fo:table-cell>
																				 
																					<!-- TOTAL  -->
																					<fo:table-cell border-right-style="solid" border-width="0.3mm">
																					<fo:block font-size="2pt">&#160;</fo:block>
																						<fo:block text-align="right">
																							<xsl:call-template name="NaN">
																								<xsl:with-param name="number" select="format-number(cbc:LineExtensionAmount, ',##0.00', 'us')"/>
																							</xsl:call-template> &#160;
																						</fo:block>
																					</fo:table-cell>	
																	
																				</fo:table-row>	 
																			</xsl:for-each>
																			 
																		 
																			<fo:table-row>		 									
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>

																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																				
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																				
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																				 
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																				<fo:table-cell  border-top-style="solid" border-width="0.1mm">
																					<fo:block font-size="0pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row>		 
																			 
																		</fo:table-body>		
																	</fo:table>	
																</fo:block>
															</fo:table-cell>	 
														</fo:table-row>   
													</fo:table-body>
												</fo:table> 

												<!-- TOTALES -->
												<fo:table>
									 
													<fo:table-column column-width="11.0cm"/> 
													<fo:table-column column-width="8.0cm"/>
													<fo:table-body>
														<fo:table-row> 
															<fo:table-cell>    
																<fo:table> 
																	<fo:table-column column-width="11.1cm"/> 
																	<fo:table-body>
																		<fo:table-row> 
																			<fo:table-cell>
																				<fo:block font-size="10pt">&#160;</fo:block>
																				<xsl:for-each select="inv:Invoice/cbc:Note | cdn:CreditNote/cbc:Note | dbn:DebitNote/cbc:Note">
																					<xsl:if test="@languageLocaleID = '1000'">  
																							<fo:block text-align="left" font-size="6.5pt">
																								  &#160;SON:&#160;<xsl:call-template name="divide_en_lineas">
																											<xsl:with-param name="val" select="."/>
																											<xsl:with-param name="c1" select="'^'"/>
																										</xsl:call-template>
																							</fo:block> 
																					</xsl:if> 	
																				</xsl:for-each>  
																				<fo:block font-size="6.5pt">&#160;<xsl:value-of select="$LeyObservacion"/></fo:block>
																			</fo:table-cell>  
																		</fo:table-row> 
																	</fo:table-body>
																</fo:table> 
															</fo:table-cell>				 
																					
															<fo:table-cell> 
																	<fo:table border-style="solid" border-width="0.3mm" border-color="black" > 
																		<fo:table-column column-width="3.0cm"/> 
																		<fo:table-column column-width="1.5cm"/> 
																		<fo:table-column column-width="3.5cm"/>  
																		<fo:table-body> 
																		 
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																					<fo:block font-size="7pt">&#160;OP GRAVADAS</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block font-size="2pt">&#160;</fo:block>
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																					<fo:block font-size="7pt" text-align="right">
																							<xsl:call-template name="NaN">
																							<xsl:with-param name="number" select="format-number($TotalGravadas, ',##0.00', 'us')"/>
																							</xsl:call-template>&#160;
																					</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row>   
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="7pt">&#160;OP INAFECTAS</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="7pt" text-align="right">
																													<xsl:call-template name="NaN">
																													<xsl:with-param name="number" select="format-number($TotalInafectas, ',##0.00', 'us')"/>
																													</xsl:call-template>&#160;
																											</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row> 
																			
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="7pt">&#160;OP EXONERADAS</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="7pt" text-align="right">
																													<xsl:call-template name="NaN">
																													<xsl:with-param name="number" select="format-number($TotalExoneradas, ',##0.00', 'us')"/>
																													</xsl:call-template>&#160;
																											</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row> 
																			
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="7pt">&#160;OP GRATUITAS</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="7pt" text-align="right">
																												<xsl:call-template name="NaN"><xsl:with-param name="number" select="format-number($TotalGratuitas, ',##0.00', 'us')"/>
																												</xsl:call-template>&#160;
																											</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row>   
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="7pt">&#160;I.G.V. 18%</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="7pt" text-align="right">
																									<xsl:call-template name="NaN">
																									<xsl:with-param name="number" select="format-number($TotalIGV, ',##0.00', 'us')"/>
																									</xsl:call-template>&#160;
																					</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row>  
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black"> 
																					<fo:block font-size="7pt">&#160;IMPORTE TOTAL</fo:block> 
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>			
																				<fo:table-cell>  
																					<fo:block text-align="center" font-size="7pt">&#160;&#160;&#160;&#160;<xsl:value-of select="$Moneda"/></fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>		
																				<fo:table-cell> 
																					<fo:block font-size="7pt" text-align="right">
																										<xsl:call-template name="NaN">
																													<xsl:with-param name="number" select="format-number(/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount |
																																		  /cdn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount |
																																		  /dbn:DebitNote/cac:RequestedMonetaryTotal/cbc:PayableAmount, ',##0.00', 'us')"/>
																										</xsl:call-template>&#160;
																									</fo:block>
																					<fo:block font-size="2pt">&#160;</fo:block>
																				</fo:table-cell>
																			</fo:table-row>    
																		</fo:table-body>
																	</fo:table>
															</fo:table-cell>	 
															
														</fo:table-row>
													</fo:table-body>
												</fo:table>
												
												
												<fo:block font-size="5pt">&#160;</fo:block>
												<!-- OBSERVACI�N  -->
												<fo:table> 
													<fo:table-column column-width="7.0cm"/> 
													<fo:table-column column-width="1.0cm"/> 
													<fo:table-column column-width="11.0cm"/> 
													<fo:table-body>
														<fo:table-row>
															<fo:table-cell>

																<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
																	<fo:table-column column-width="3.0cm"/>  
																	<fo:table-column column-width="4.0cm"/> 
																	<fo:table-body>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;PLACA:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$Placa"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;TURNO:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$Turno"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;LADO:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$Lado"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;ATENDIDO POR:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$AtentidoPor"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;CONDICI�N DE PAGO:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$Condicion"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																		<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																			<fo:table-cell>
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;ODOMETRO:</fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell> 
																			<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:block font-size="3pt">&#160;</fo:block>
																				<fo:block font-size="7pt">&#160;&#160;<xsl:value-of select="$Odometro"/></fo:block>
																				<fo:block font-size="3pt">&#160;</fo:block>
																			</fo:table-cell>
																		</fo:table-row>
																	</fo:table-body>
																</fo:table> 

															</fo:table-cell>
															<fo:table-cell>
																<fo:block font-size="3pt">&#160;</fo:block> 
															</fo:table-cell>
															<fo:table-cell>
																<xsl:if test="$Tipo = '01' or $Tipo = '07'">
																	
																	<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
																		<fo:table-column column-width="3.0cm"/>  
																		<fo:table-column column-width="4.0cm"/> 
																		<fo:table-column column-width="4.0cm"/> 
																		<fo:table-body>
																			<xsl:variable name="detraccion-length" select="string-length(/inv:Invoice/cac:PaymentTerms/cbc:PaymentPercent | /cdn:CreditNote/cac:PaymentTerms/cbc:PaymentPercent)"/>
																		
																			<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																				<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A" number-columns-spanned="3">
																					<fo:block font-size="3pt">&#160;</fo:block>
																					<fo:block font-size="7pt" color="#FFFFFF">&#160;&#160;FORMA DE PAGO: 
																					 
																					<xsl:if test="$detraccion-length > 0">
																						 
																						  <xsl:value-of select="translate(/inv:Invoice/cac:PaymentTerms[2]/cbc:PaymentMeansID | /cdn:CreditNote/cac:PaymentTerms[2]/cbc:PaymentMeansID, $lowercase, $uppercase)" />  
																						 
																					</xsl:if>
																					<xsl:if test="$detraccion-length = 0">
																															 
																						  <xsl:value-of select="translate(/inv:Invoice/cac:PaymentTerms/cbc:PaymentMeansID | /cdn:CreditNote/cac:PaymentTerms/cbc:PaymentMeansID, $lowercase, $uppercase)" /> 
																						 
																					</xsl:if>
																						
																						
																					</fo:block>
																					<fo:block font-size="3pt">&#160;</fo:block>
																				</fo:table-cell>  
																			</fo:table-row>
																			
																			<xsl:if test="$detraccion-length > 0">
																				<xsl:if test="/inv:Invoice/cac:PaymentTerms[2]/cbc:PaymentMeansID != 'Contado' or 
																							  /cdn:CreditNote/cac:PaymentTerms[2]/cbc:PaymentMeansID != 'Contado'">
																					<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																						<fo:table-cell number-columns-spanned="3">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt">&#160;&#160;MONTO PENDIENTE DE PAGO: <xsl:value-of select="$PendientePago"/></fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>  
																					</fo:table-row>  
																					<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">CUOTA</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell> 
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">MONTO</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">FECHA</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>
																					</fo:table-row> 
																					
																					<xsl:for-each select="/inv:Invoice/cac:PaymentTerms |
																										  /cdn:CreditNote/cac:PaymentTerms ">	 
																						<xsl:if test="position() > 2">
																							<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:PaymentMeansID"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell> 
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:Amount"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell>
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:PaymentDueDate"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell>
																							</fo:table-row> 
																						</xsl:if> 
																					</xsl:for-each>
																					
																				</xsl:if>
																			</xsl:if>
																			<xsl:if test="$detraccion-length = 0">
																				<xsl:if test="/inv:Invoice/cac:PaymentTerms/cbc:PaymentMeansID != 'Contado' or 
																							  /cdn:CreditNote/cac:PaymentTerms/cbc:PaymentMeansID != 'Contado'">
																					<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																						<fo:table-cell number-columns-spanned="3">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt">&#160;&#160;MONTO PENDIENTE DE PAGO: <xsl:value-of select="$PendientePago"/></fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>  
																					</fo:table-row>  
																					<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">CUOTA</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell> 
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">MONTO</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>
																						<fo:table-cell border-style="solid" border-width="0.3mm" border-color="black" background-color="#1A344A">
																							<fo:block font-size="3pt">&#160;</fo:block>
																							<fo:block font-size="7pt" text-align="center" color="#FFFFFF">FECHA</fo:block>
																							<fo:block font-size="3pt">&#160;</fo:block>
																						</fo:table-cell>
																					</fo:table-row> 
																					<xsl:for-each select="/inv:Invoice/cac:PaymentTerms |
																										  /cdn:CreditNote/cac:PaymentTerms ">	 
																						<xsl:if test="position() > 1">
																							<fo:table-row border-style="solid" border-width="0.3mm" border-color="black">
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:PaymentMeansID"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell> 
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:Amount"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell>
																								<fo:table-cell border-style="solid" border-width="0.3mm">
																									<fo:block font-size="3pt">&#160;</fo:block>
																									<fo:block font-size="7pt" text-align="center"><xsl:value-of select="cbc:PaymentDueDate"/></fo:block>
																									<fo:block font-size="3pt">&#160;</fo:block>
																								</fo:table-cell>
																							</fo:table-row> 
																						</xsl:if> 
																					</xsl:for-each>
																				</xsl:if>
																			</xsl:if>
							 
																		</fo:table-body>
																	</fo:table> 
																</xsl:if>
																
																<fo:block font-size="3pt">&#160;</fo:block>
															</fo:table-cell>
														</fo:table-row>
													</fo:table-body>
												</fo:table> 
												
												
												
												<fo:block font-size="10pt">&#160;</fo:block>
												<!-- OBSERVACI�N  -->
												<fo:table border-style="solid" border-width="0.3mm" border-color="black"> 
													<fo:table-column column-width="19.0cm"/> 
													<fo:table-body>
													<fo:table-row>
														<fo:table-cell>
															<fo:block font-size="3pt">&#160;</fo:block>
															<fo:block font-size="7pt">&#160;&#160;OBSERVACI�N:&#160;<xsl:value-of select="$Observacion"/></fo:block>
															<fo:block font-size="3pt">&#160;</fo:block>
														</fo:table-cell>
													</fo:table-row>
												</fo:table-body>
												</fo:table> 
											
											<!-- FIN TABLA PRINCIPAL -->	 
											</fo:table-cell>	 
										</fo:table-row>
									</fo:table-body>
								</fo:table>
				
				
				</xsl:otherwise>
			</xsl:choose>
			  
			<!-- TEXTOS AL PIE DE PAGINA - TIMBRE -->
			<fo:table>
				<fo:table-column column-width="1cm"/>
				<fo:table-column column-width="19cm"/>
				<fo:table-body>
					
					<fo:table-row>
						<fo:table-cell><fo:block>&#160;</fo:block></fo:table-cell>
						<fo:table-cell text-align="center">
							<fo:block font-size="5pt">&#160;</fo:block>	
						  
							<fo:block font-size="5pt">&#160;</fo:block>	
							
							<fo:block font-size="6pt" text-align="center">Representaci�n impresa de <xsl:value-of select="$TpoCPE"/></fo:block>
							<fo:block font-size="6pt" text-align="center">&#160;</fo:block> 
						</fo:table-cell> 
					</fo:table-row>
				</fo:table-body>
			</fo:table> 
					  
 
		</fo:block>
	</xsl:template>
	
	<xsl:template name="seq">
		<xsl:param name="start"/>
		<xsl:param name="end"/>
		<xsl:param name="step" select="1"/>
		<xsl:if test="$start &lt;= $end">
			<item>
				<xsl:value-of select="$start"/>
			</item>
			<xsl:call-template name="seq">
				<xsl:with-param name="start" select="$start + $step"/>
				<xsl:with-param name="end" select="$end"/>
				<xsl:with-param name="step" select="$step"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="/">
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
			<fo:layout-master-set> 
				<fo:simple-page-master master-name="Letter">
					<fo:region-body margin-top="0.01cm" margin-bottom="0.01cm" margin-left="0cm" margin-right="0.5cm"/>
				</fo:simple-page-master> 
			</fo:layout-master-set> 
			<fo:page-sequence master-reference="Letter">
				<fo:flow flow-name="xsl-region-body">
					<xsl:variable name="page-numbers">
						<xsl:call-template name="seq">
							<xsl:with-param name="start" select="1"/>
							<xsl:with-param name="end" select="1"/>
							<xsl:with-param name="step" select="1"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="document" select="/"/>
					<xsl:for-each select="exsl:node-set($page-numbers)/item">
						<xsl:variable name="page-number" select="number(.)"/>
						<xsl:for-each select="exsl:node-set($document)[1]">
							<xsl:call-template name="visualizacion-documento">
								<xsl:with-param name="con-cedible" select="$page-number = 2 or ($xsl.cedible = 'true')"/>
								<xsl:with-param name="page-number" select="$page-number"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:for-each>
				</fo:flow>
			</fo:page-sequence> 
		</fo:root>
		<xsl:if test="$ca4xml = 'si'">
			<xsl:message>HOLA MUNDO CA4XML</xsl:message>
		</xsl:if>
	</xsl:template>
	<!-- SCRIPT ............................................................................................................-->
	<!-- TIPO DTE ............................................................................................................-->
	<xsl:template name="DTEName">
		<xsl:param name="codDTE"/>
		<xsl:variable name="respDTE">
			<codigor codDTE="33">FACTURA ELECTR&#211;NICA</codigor>
			<codigor codDTE="34">FACTURA NO AFECTA O EXENTA ELECTR&#211;NICA</codigor>
			<codigor codDTE="52">GU&#205;A DE DESPACHO ELECTR&#211;NICA</codigor>
			<codigor codDTE="56">NOTA DE D&#201;BITO ELECTR&#211;NICA</codigor>
			<codigor codDTE="61">NOTA DE CR&#201;DITO ELECTR&#211;NICA</codigor>
			<codigor codDTE="39">BOLETA ELECTR&#211;NICA</codigor>
			<codigor codDTE="SET">SET</codigor>
		</xsl:variable>
		<xsl:variable name="respuesta">
			<xsl:for-each select="exsl:node-set($respDTE)/codigor">
				<xsl:if test="@codDTE = $codDTE">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$respuesta"/>
	</xsl:template>
	<!-- TIPO DTE  PERU............................................................................................................-->
	<xsl:template name="DTENameperu">
		<xsl:param name="codDTE"/>
		<xsl:variable name="respDTE">
			<codigor codDTE="01">FACTURA ELECTR&#211;NICA</codigor>
			<codigor codDTE="03">BOLETA DE VENTA ELECTR&#211;NICA</codigor>
		</xsl:variable>
		<xsl:variable name="respuesta">
			<xsl:for-each select="exsl:node-set($respDTE)/codigor">
				<xsl:if test="@codDTE = $codDTE">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$respuesta"/>
	</xsl:template>

	<xsl:template name="xml_escape">
		<!--FUNCION QUE PERMITE EL ESCAPEO DE CARACTERES ESPECIALES EN EL TIMBRE-->
		<xsl:param name="input"/>
		<xsl:variable name="first" select="substring($input, 1, 1)"/>
		<xsl:variable name="tail" select="substring($input, 2)"/>
		<xsl:choose>
			<xsl:when test="$first = '&amp;' ">&amp;amp;</xsl:when>
			<xsl:when test="$first = '&gt;'  ">&amp;gt;</xsl:when>
			<xsl:when test="$first = '&lt;'  ">&amp;lt;</xsl:when>
			<xsl:when test="$first = '&quot;'">&amp;quot;</xsl:when>
			<xsl:when test='$first = "&apos;"'>&amp;apos;</xsl:when>
			<xsl:when test='$first = "&apos;"'>&amp;apos;</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$first"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$tail">
			<xsl:call-template name="xml_escape">
				<xsl:with-param name="input">
					<xsl:value-of select="$tail"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="ca4web-data-escape">
		<xsl:param name="url-data"/>
		<xsl:variable name="data-length" select="string-length($url-data)"/>
		<xsl:choose>
			<xsl:when test="$data-length = 1">
				<xsl:choose>
					<xsl:when test="$url-data = '&#x9;'">$09</xsl:when>
					<xsl:when test="$url-data = '&#xA;'">$0a</xsl:when>
					<xsl:when test="$url-data = '&#xD;'">$0d</xsl:when>
					<xsl:when test="$url-data = ' '">$20</xsl:when>
					<xsl:when test="$url-data = '&quot;'">$22</xsl:when>
					<xsl:when test="$url-data = '$'">$24</xsl:when>
					<xsl:when test="$url-data = '%'">$25</xsl:when>
					<xsl:when test="$url-data = '&amp;'">$26</xsl:when>
					<xsl:when test="$url-data = '+'">$2b</xsl:when>
					<xsl:when test="$url-data = '/'">$2f</xsl:when>
					<xsl:when test="$url-data = '&lt;'">$3c</xsl:when>
					<xsl:when test="$url-data = '='">$3d</xsl:when>
					<xsl:when test="$url-data = '&gt;'">$3e</xsl:when>
					<xsl:when test="$url-data = '\F3'">%C3%B3</xsl:when>
					<xsl:when test="$url-data = '?'">$3f</xsl:when>
					<xsl:when test="$url-data = '|'">$7C</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$url-data"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="ca4web-data-escape">
					<xsl:with-param name="url-data" select="substring($url-data, 1, $data-length div 2)"/>
				</xsl:call-template>
				<xsl:call-template name="ca4web-data-escape">
					<xsl:with-param name="url-data" select="substring($url-data, 1 + ($data-length div 2), $data-length - ($data-length div 2))"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--FUNCION PARA FORMATEAR RUT-->
	<xsl:template name="formatearRut">
		<xsl:param name="input"/>
		<xsl:variable name="rut" select="substring-before($input, '-')"/>
		<xsl:variable name="last" select="substring($rut,string-length($rut)-2,3)"/>
		<xsl:variable name="middle" select="substring($rut,string-length($rut)-5,3)"/>
		<xsl:variable name="first">
			<xsl:choose>
				<xsl:when test="string-length($rut)=7">
					<xsl:value-of select="substring($rut,1,1)"/>
				</xsl:when>
				<xsl:when test="string-length($rut)=8">
					<xsl:value-of select="substring($rut,1,2)"/>
				</xsl:when>
				<xsl:when test="string-length($rut)=9">
					<xsl:value-of select="substring($rut,1,3)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="dv" select="substring-after($input, '-')"/>
		<xsl:value-of select="concat($first,'.',$middle,'.',$last, '-', $dv)"/>
	</xsl:template>
	<xsl:template name="format-fecha-all">
		<xsl:param name="input" select="''"/>
		<xsl:param name="nombre" select="''"/>
		<xsl:param name="separador" select="'-'"/>
		<xsl:variable name="year" select="substring($input, 1, 4)"/>
		<xsl:variable name="mes">
			<xsl:call-template name="dos-digitos">
				<xsl:with-param name="mes-id" select="substring($input, 6, 2)"/>
				<xsl:with-param name="id" select="'mes'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="day">
			<xsl:call-template name="dos-digitos">
				<xsl:with-param name="mes-id" select="substring($input, 9, 2)"/>
				<xsl:with-param name="id" select="'dia'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$nombre = 'nombre'">
				<xsl:variable name="nom">
					<xsl:call-template name="nombre-mes">
						<xsl:with-param name="tip" select="$mes"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($day, $separador, $nom, $separador, $year)"/>
			</xsl:when>
			<xsl:when test="$nombre = 'corto'">
				<xsl:variable name="nomb">
					<xsl:call-template name="nom-mes">
						<xsl:with-param name="tip" select="$mes"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($day, $separador, $nomb, $separador, $year)"/>
			</xsl:when>
			<xsl:when test="$nombre = 'nombremayus'">
				<xsl:variable name="nomM">
					<xsl:call-template name="nombre-mes-mayus">
						<xsl:with-param name="tip" select="$mes"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($day, $separador, $nomM, $separador, $year)"/>
			</xsl:when>
			<xsl:when test="$nombre = 'mayuscorto'">
				<xsl:variable name="nomMC">
					<xsl:call-template name="nom-mes-mayus">
						<xsl:with-param name="tip" select="$mes"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($day, $separador, $nomMC, $separador, $year)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($day, $separador, $mes, $separador, $year)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--FORMA DE PAGO-->
	<xsl:template name="Fma-Pago">
		<xsl:param name="Fma-Pago"/>
		<xsl:variable name="respDTE">
			<codigor Fma-Pago="1">Contado</codigor>
			<codigor Fma-Pago="2">Cr&#233;dito</codigor>
			<codigor Fma-Pago="3">Sin Costo (entrega gratuita)</codigor>
		</xsl:variable>
		<xsl:variable name="respuesta">
			<xsl:for-each select="exsl:node-set($respDTE)/codigor">
				<xsl:if test="@Fma-Pago = $Fma-Pago">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$respuesta"/>
	</xsl:template>
	<!-- ............................................................................................................ -->
	<xsl:template name="codigo_ref">
		<xsl:param name="codRef"/>
		<xsl:variable name="respDTE">
			<codigor codRef="1">Anula Documento </codigor>
			<codigor codRef="2">Corrige Texto </codigor>
			<codigor codRef="3">Corrige Montos </codigor>
		</xsl:variable>
		<xsl:variable name="respuesta">
			<xsl:for-each select="exsl:node-set($respDTE)/codigor">
				<xsl:if test="@codRef = $codRef">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$respuesta"/>
	</xsl:template>
	<xsl:template name="divide_en_lineas">
		<!-- TEMPLATE PARA SEPARAR EN L\CDNEAS CRISTIAN ACUNA, MODIFICADA POR EPS PARA QUE TOME SALTO DE LINEA DEL FINAL-->
		<xsl:param name="val"/>
		<xsl:param name="c1"/>
		<xsl:choose>
			<xsl:when test="string-length(substring-after($val, $c1)) = 0">
				<xsl:choose>
					<xsl:when test="contains($val, $c1)">
						<xsl:value-of select="substring-before($val, $c1)"/>
					</xsl:when> 
					<xsl:otherwise>
						<xsl:value-of select="$val"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before($val, $c1)"/>
				<fo:block>
					<xsl:call-template name="divide_en_lineas">
						<xsl:with-param name="val">
					&#160;<xsl:value-of select="substring-after($val, $c1)"/>
						</xsl:with-param>
						<xsl:with-param name="c1">
							<xsl:value-of select="$c1"/>
						</xsl:with-param>
					</xsl:call-template>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................ -->
	<xsl:template name="Traslado">
		<xsl:param name="codTras"/>
		<xsl:variable name="respDTE">
			<codigor codTras="1">Constituye venta</codigor>
			<codigor codTras="2">Venta por efectuar</codigor>
			<codigor codTras="3">Consignaciones</codigor>
			<codigor codTras="4">Entrega gratuita</codigor>
			<codigor codTras="5">Traslado interno</codigor>
			<codigor codTras="6">Otro traslado no venta</codigor>
			<codigor codTras="7">Guia de devolucion</codigor>
		</xsl:variable>
		<xsl:variable name="respuesta">
			<xsl:for-each select="exsl:node-set($respDTE)/codigor">
				<xsl:if test="@codTras = $codTras">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$respuesta"/>
	</xsl:template>
	<!-- ............................................................................................................-->
	<xsl:template name="Tipo-DocRef">
		<xsl:param name="tip"/>
		<xsl:variable name="Tipo-DocRef">
			<TipoDoc tip="30">Factura</TipoDoc>
			<TipoDoc tip="35">Boleta</TipoDoc>
			<TipoDoc tip="50">Guia De Despacho</TipoDoc>
			<TipoDoc tip="52">Guia De Despacho Electr&#243;nica</TipoDoc>
			<TipoDoc tip="38">Boleta Exenta</TipoDoc>
			<TipoDoc tip="39">Boleta  Electr&#243;nica</TipoDoc>
			<TipoDoc tip="40">Liquidaci&#243;n Factura</TipoDoc>
			<TipoDoc tip="41">Boleta Exenta Electr&#243;nica</TipoDoc>
			<TipoDoc tip="43">Liquidaci&#243;n Factura Electr&#243;nica</TipoDoc>
			<TipoDoc tip="45">Factura De Compra</TipoDoc>
			<TipoDoc tip="55">Nota De D&#233;bito</TipoDoc>
			<TipoDoc tip="60">Nota De Cr&#233;dito</TipoDoc>
			<TipoDoc tip="32">Factura No Afecta O Exenta</TipoDoc>
			<TipoDoc tip="33">Factura Electr&#243;nica</TipoDoc>
			<TipoDoc tip="34">Factura No Afecta O Exenta Electr&#243;nica</TipoDoc>
			<TipoDoc tip="46">Factura De Compra Electr&#243;nica</TipoDoc>
			<TipoDoc tip="56">Nota De D&#233;bito Electr&#243;nica</TipoDoc>
			<TipoDoc tip="61">Nota De Cr&#233;dito Electr&#243;nica</TipoDoc>
			<TipoDoc tip="103">Liquidaci&#243;n</TipoDoc>
			<TipoDoc tip="110">Factura de Exportaci&#243;n Electr&#243;nica</TipoDoc>
			<TipoDoc tip="111">Nota de D&#233;bito de Exportaci&#243;n Electr&#243;nica</TipoDoc>
			<TipoDoc tip="112">Nota de Cr&#233;dito de Exportaci&#243;n Electr&#243;nica</TipoDoc>
			<TipoDoc tip="801">Orden De Compra</TipoDoc>
			<TipoDoc tip="802">Nota de Pedido</TipoDoc>
			<TipoDoc tip="803">Contrato </TipoDoc>
			<TipoDoc tip="804">Resoluci&#243;n </TipoDoc>
			<TipoDoc tip="805">Proceso ChileCompra</TipoDoc>
			<TipoDoc tip="806">Ficha ChileCompra</TipoDoc>
			<TipoDoc tip="807">DUS</TipoDoc>
			<TipoDoc tip="808">B/L</TipoDoc>
			<TipoDoc tip="809">AWB</TipoDoc>
			<TipoDoc tip="810">MIC/DTA</TipoDoc>
			<TipoDoc tip="811">Carta De Porte</TipoDoc>
			<TipoDoc tip="812">Resoluci&#243;n Del SNA</TipoDoc>
			<TipoDoc tip="813">Pasaporte </TipoDoc>
			<TipoDoc tip="814">Certificado De Dep&#243;sito Bolsa Prod. Chile</TipoDoc>
			<TipoDoc tip="815">Vale De Prenda Bolsa Prod. Chile</TipoDoc>
			<TipoDoc tip="OC">Orden De Compra</TipoDoc>
			<TipoDoc tip="NV">Nota De Venta</TipoDoc>
			<TipoDoc tip="PED">Pedido</TipoDoc>
			<TipoDoc tip="HES">HES</TipoDoc>
			<TipoDoc tip="HEM">HEM</TipoDoc>
			<TipoDoc tip="SET">SET</TipoDoc>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($Tipo-DocRef)/TipoDoc">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="$resultado"/>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="nombre-mes">
		<!-- ESTA FUNCION RECIBE UN NUMERO Y DEVUELVE EL NOMBRE DEL MES QUE
	     	  LE CORRESPONDE SE UTILIZA PARA PCL PRINCIPALMENTE.
	     -->
		<xsl:param name="tip"/>
		<xsl:variable name="mes">
			<TipoMes tip="01">Enero</TipoMes>
			<TipoMes tip="02">Febrero</TipoMes>
			<TipoMes tip="03">Marzo</TipoMes>
			<TipoMes tip="04">Abril</TipoMes>
			<TipoMes tip="05">Mayo</TipoMes>
			<TipoMes tip="06">Junio</TipoMes>
			<TipoMes tip="07">Julio</TipoMes>
			<TipoMes tip="08">Agosto</TipoMes>
			<TipoMes tip="09">Septiembre</TipoMes>
			<TipoMes tip="10">Octubre</TipoMes>
			<TipoMes tip="11">Noviembre</TipoMes>
			<TipoMes tip="12">Diciembre</TipoMes>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($mes)/TipoMes">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$resultado">
				<xsl:value-of select="$resultado"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="nombre-mes-mayus">
		<!-- ESTA FUNCION RECIBE UN NUMERO Y DEVUELVE EL NOMBRE DEL MES QUE
	     	  LE CORRESPONDE SE UTILIZA PARA PCL PRINCIPALMENTE.     -->
		<xsl:param name="tip"/>
		<xsl:variable name="mes">
			<TipoMes tip="01">ENERO</TipoMes>
			<TipoMes tip="02">FEBRERO</TipoMes>
			<TipoMes tip="03">MARZO</TipoMes>
			<TipoMes tip="04">ABRIL</TipoMes>
			<TipoMes tip="05">MAYO</TipoMes>
			<TipoMes tip="06">JUNIO</TipoMes>
			<TipoMes tip="07">JULIO</TipoMes>
			<TipoMes tip="08">AGOSTO</TipoMes>
			<TipoMes tip="09">SEPTIEMBRE</TipoMes>
			<TipoMes tip="10">OCTUBRE</TipoMes>
			<TipoMes tip="11">NOVIEMBRE</TipoMes>
			<TipoMes tip="12">DICIEMBRE</TipoMes>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($mes)/TipoMes">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$resultado">
				<xsl:value-of select="$resultado"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="nom-cpe">
		<!-- ESTA FUNCION RECIBE 02 Y DEVUELVE FEB EN MINUSCULA-->
		<xsl:param name="tip"/>
		<xsl:variable name="CPE">
			<TipoCPE tip="01">FAC</TipoCPE>
			<TipoCPE tip="03">BOL</TipoCPE>
			<TipoCPE tip="07">NC</TipoCPE>
			<TipoCPE tip="08">ND</TipoCPE>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($CPE)/TipoCPE">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$resultado">
				<xsl:value-of select="$resultado"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="nom-mes">
		<!-- ESTA FUNCION RECIBE 02 Y DEVUELVE FEB EN MINUSCULA-->
		<xsl:param name="tip"/>
		<xsl:variable name="mes">
			<TipoMes tip="01">Ene</TipoMes>
			<TipoMes tip="02">Feb</TipoMes>
			<TipoMes tip="03">Mar</TipoMes>
			<TipoMes tip="04">Abr</TipoMes>
			<TipoMes tip="05">May</TipoMes>
			<TipoMes tip="06">Jun</TipoMes>
			<TipoMes tip="07">Jul</TipoMes>
			<TipoMes tip="08">Ago</TipoMes>
			<TipoMes tip="09">Sep</TipoMes>
			<TipoMes tip="10">Oct</TipoMes>
			<TipoMes tip="11">Nov</TipoMes>
			<TipoMes tip="12">Dic</TipoMes>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($mes)/TipoMes">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$resultado">
				<xsl:value-of select="$resultado"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="nom-mes-mayus">
		<!-- ESTA FUNCION RECIBE 02 Y DEVUELVE FEB EN MAYUSCULA-->
		<xsl:param name="tip"/>
		<xsl:variable name="mes">
			<TipoMes tip="01">ENE</TipoMes>
			<TipoMes tip="02">FEB</TipoMes>
			<TipoMes tip="03">MAR</TipoMes>
			<TipoMes tip="04">ABR</TipoMes>
			<TipoMes tip="05">MAY</TipoMes>
			<TipoMes tip="06">JUN</TipoMes>
			<TipoMes tip="07">JUL</TipoMes>
			<TipoMes tip="08">AGO</TipoMes>
			<TipoMes tip="09">SEP</TipoMes>
			<TipoMes tip="10">OCT</TipoMes>
			<TipoMes tip="11">NOV</TipoMes>
			<TipoMes tip="12">DIC</TipoMes>
		</xsl:variable>
		<xsl:variable name="resultado">
			<xsl:for-each select="exsl:node-set($mes)/TipoMes">
				<xsl:if test="@tip = $tip">
					<xsl:value-of select="."/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$resultado">
				<xsl:value-of select="$resultado"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tip"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................................................................ -->
	<xsl:template name="dos-digitos">
		<xsl:param name="mes-id" select="0"/>
		<xsl:param name="id" select="'mes'"/>
		<xsl:choose>
			<xsl:when test="$id ='mes'">
				<!--PARA MES-->
				<xsl:choose>
					<xsl:when test="number($mes-id) &gt;= 1 and number($mes-id) &lt;= 12">
						<xsl:value-of select="format-number(number($mes-id), '00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ERR"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!--PARA DIA-->
				<xsl:choose>
					<xsl:when test="$id = 'dia'">
						<xsl:value-of select="format-number(number($mes-id), '00')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="ERR"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="NaN">
		<xsl:param name="number"/>
		<xsl:choose>
			<xsl:when test="string($number) != 'NaN'">
				<xsl:value-of select="$number"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="' '"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="formatea-number">
		<xsl:param name="val"/>
		<xsl:param name="format-string" select="'.##0'"/>
		<xsl:param name="locale" select="'cl'"/>
		<xsl:variable name="result" select="format-number($val, $format-string, $locale)"/>
		<xsl:choose>
			<xsl:when test="$result = 'NaN'">
				<xsl:value-of select="$val"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$result"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="TipoImp">
		<!-- Permite dar titulo al tipo de impuesto adicional de los totales
      2010-03-10 EPS modifica actualizando tabla de impuestos y titulos -->
		<xsl:param name="tipo"/>
		<xsl:choose>
			<xsl:when test="$tipo[.='14']">Adic. Marg. Comer.</xsl:when>
			<xsl:when test="$tipo[.='15']">Reten. Total Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='17']">Adic. Fae. Carne Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='18']">Adic. Ant. Carne Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='19']">Adic. Ant. Har. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='23']">Imp. Adic. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='24']">I.L.A. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='25']">I.L.A. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='26']">I.L.A. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='27']">Imp. Adic. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='28']">Imp. Espec. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='30']">Reten. Leg. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='31']">Reten. Silv. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='32']">Reten. Ganado Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='33']">Reten. Madera Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='34']">Reten. Trigo Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='35']">Esp. Gasolina Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='36']">Reten. Arroz Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='37']">Reten. Hidrob. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='38']">Reten. Chatarra Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='39']">Reten. PPA Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='41']">Reten. Const. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='44']">Imp. Adic. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='45']">Imp. Adic. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='46']">Reten. Oro Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='47']">Reten. Cartones Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='48']">Reten. Franb. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='49']">Imp. Adic. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='50']">Adic. Prepago Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='301']">Reten. Leg. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='321']">Reten. Ganado Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='331']">Reten. Madera Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='341']">Reten. Trigo Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='361']">Reten. Arroz Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='371']">Reten. Hidrob. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:when test="$tipo[.='481']">Reten. Framb. Cod: <xsl:value-of select="$tipo"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$tipo"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ............................................................................................................ -->
	<xsl:template name="NombFirma">
		<xsl:param name="RutFirma"/>
		<xsl:choose>
			<xsl:when test="$RutFirma ='9995380-2'">LUIS VARAS</xsl:when>
			<xsl:when test="$RutFirma ='9960445-K'">LUIS CORTES GANA</xsl:when>
			<xsl:when test="$RutFirma ='9946073-3'">DEMETRIO MARTINEZ SAPSFORD</xsl:when>
			<xsl:when test="$RutFirma ='9872938-0'">JOSE ALTAMIRANO</xsl:when>
			<xsl:when test="$RutFirma ='9699152-5'">MAXIMO CARDOZA</xsl:when>
			<xsl:when test="$RutFirma ='9520784-7'">HECTOR POBLETE UREN</xsl:when>
			<xsl:when test="$RutFirma ='9426654-8'">FRANCISCO ARACENA ROJAS</xsl:when>
			<xsl:when test="$RutFirma ='9289450-9'">CARLOS MU\D1OZ</xsl:when>
			<xsl:when test="$RutFirma ='9273669-5'">JOSE AGUILERA</xsl:when>
			<xsl:when test="$RutFirma ='9266057-5'">CARLOS PULGAR NEIRA</xsl:when>
			<xsl:when test="$RutFirma ='9238866-2'">JOEL RIVAS</xsl:when>
			<xsl:when test="$RutFirma ='9176941-7'">NIBALDO VARAS</xsl:when>
			<xsl:when test="$RutFirma ='8835733-7'">MAURICIO MILLA ROMERO</xsl:when>
			<xsl:when test="$RutFirma ='8816446-6'">MILTON VILLAGRA</xsl:when>
			<xsl:when test="$RutFirma ='8765712-4'">OSCAR GOMEZ GUZMAN</xsl:when>
			<xsl:when test="$RutFirma ='8653929-2'">MANUEL ROMERO MEZA</xsl:when>
			<xsl:when test="$RutFirma ='8291945-7'">PETER BROCHETT</xsl:when>
			<xsl:when test="$RutFirma ='7970692-2'">CARLOS ARAYA SOTO</xsl:when>
			<xsl:when test="$RutFirma ='7922428-6'">MIGUEL OLIVARES NEIRA</xsl:when>
			<xsl:when test="$RutFirma ='7921161-3'">LUIS AGUIRRE</xsl:when>
			<xsl:when test="$RutFirma ='7872197-9'">DANIEL ROJAS</xsl:when>
			<xsl:when test="$RutFirma ='7709791-0'">CARLOS MIRANDA</xsl:when>
			<xsl:when test="$RutFirma ='7666045-K'">MIGUEL RODRIGUEZ MOYA</xsl:when>
			<xsl:when test="$RutFirma ='7640714-2'">ERIC DOUGLAS</xsl:when>
			<xsl:when test="$RutFirma ='7358803-0'">JORGE GAETE</xsl:when>
			<xsl:when test="$RutFirma ='7276725-K'">ALEJANDRO OLIVARES CONTRERAS</xsl:when>
			<xsl:when test="$RutFirma ='7054276-5'">ALVARO ZARATE LOPEZ</xsl:when>
			<xsl:when test="$RutFirma ='7049600-3'">CARLOS DUPIN</xsl:when>
			<xsl:when test="$RutFirma ='6973331-K'">CESAR CANETE GUERRERO</xsl:when>
			<xsl:when test="$RutFirma ='6938131-6'">OSCAR ARAYA PINTO</xsl:when>
			<xsl:when test="$RutFirma ='6622263-2'">ALEJANDRO GARCIA</xsl:when>
			<xsl:when test="$RutFirma ='6409826-8'">LUIS ORTIZ</xsl:when>
			<xsl:when test="$RutFirma ='6037620-4'">ALAJANDRO VILLAR</xsl:when>
			<xsl:when test="$RutFirma ='5710452-K'">JORGE ARTEAGA CANALES</xsl:when>
			<xsl:when test="$RutFirma ='22236574-0'">JUANITA OGLIASTRI JAIME</xsl:when>
			<xsl:when test="$RutFirma ='17362189-2'">PAULINA SEGOVIA BUGUENO</xsl:when>
			<xsl:when test="$RutFirma ='17019446-2'">YENNY SIGNIA CRUZ VARGAS</xsl:when>
			<xsl:when test="$RutFirma ='17018068-2'">MADELINE PIZARRO PIZARRO</xsl:when>
			<xsl:when test="$RutFirma ='16436900-5'">MARIA JOSE MONDACA ESCOBAR</xsl:when>
			<xsl:when test="$RutFirma ='15590057-1'">CRISTIAN GONZALEZ QUINTANA</xsl:when>
			<xsl:when test="$RutFirma ='15514491-2'">MANUEL FERNANDEZ ZULETA</xsl:when>
			<xsl:when test="$RutFirma ='15412832-8'">LUIS RODRIGUEZ FUENZALIDA</xsl:when>
			<xsl:when test="$RutFirma ='15327718-4'">CAROLINA POBLETE VILLOUTA</xsl:when>
			<xsl:when test="$RutFirma ='15147892-1'">FELIPE PORTILLA ESPINOZA</xsl:when>
			<xsl:when test="$RutFirma ='13880948-K'">CESAR HUGO ESCOBAR JAQUE</xsl:when>
			<xsl:when test="$RutFirma ='13669751-K'">PABLO VERDUGO GARCES</xsl:when>
			<xsl:when test="$RutFirma ='13642339-8'">MARCO INOSTROZA BARRAZA</xsl:when>
			<xsl:when test="$RutFirma ='13426368-7'">MAGALY ROMERO CHAVEZ</xsl:when>
			<xsl:when test="$RutFirma ='13420054-5'">SIDNEY ROJAS MORALES</xsl:when>
			<xsl:when test="$RutFirma ='13194602-3'">JENNY ROJAS</xsl:when>
			<xsl:when test="$RutFirma ='13182984-1'">GIANNI PIMENTEL</xsl:when>
			<xsl:when test="$RutFirma ='13093799-3'">PAULINA CONTRERAS CLAVERIA</xsl:when>
			<xsl:when test="$RutFirma ='12841470-3'">MAURICIO CAMPOS OLIVARES</xsl:when>
			<xsl:when test="$RutFirma ='12841022-8'">HECTOR VERA GONZALEZ</xsl:when>
			<xsl:when test="$RutFirma ='12777732-2'">LUIS MUJICA HUERTA</xsl:when>
			<xsl:when test="$RutFirma ='12578575-1'">ALAIN SARAVIA</xsl:when>
			<xsl:when test="$RutFirma ='12572454-K'">RODRIGO AGUILERA GALLEGUILLOS</xsl:when>
			<xsl:when test="$RutFirma ='12218685-7'">VICTOR YAITE CIFUENTES</xsl:when>
			<xsl:when test="$RutFirma ='12217024-1'">JUAN ANTONIO REYES RAMIREZ</xsl:when>
			<xsl:when test="$RutFirma ='12216791-7'">DALTON VERGARA ARDILES</xsl:when>
			<xsl:when test="$RutFirma ='12215981-7'">OWEL MU\D1OZ</xsl:when>
			<xsl:when test="$RutFirma ='12170538-9'">ROBINSON MALUENDA CARVAJAL</xsl:when>
			<xsl:when test="$RutFirma ='11845920-2'">GINO ZAFFIRI MUNOZ</xsl:when>
			<xsl:when test="$RutFirma ='11722160-1'">JUAN ARAMAYO JIMENEZ</xsl:when>
			<xsl:when test="$RutFirma ='11721813-9'">JUAN MANUEL VEGA OPAZO</xsl:when>
			<xsl:when test="$RutFirma ='11719757-3'">RICHARD PERALTA</xsl:when>
			<xsl:when test="$RutFirma ='11616716-6'">DRAGO PERIC</xsl:when>
			<xsl:when test="$RutFirma ='11511929-K'">GERMAN MARIN</xsl:when>
			<xsl:when test="$RutFirma ='11508809-2'">CRISTIAN ZUNIGA SANTIBANEZ</xsl:when>
			<xsl:when test="$RutFirma ='11467068-5'">IVO CORNEJO</xsl:when>
			<xsl:when test="$RutFirma ='11377548-3'">JOSE GAONAL</xsl:when>
			<xsl:when test="$RutFirma ='11219943-8'">BLADIMIR RIVERA ROJAS</xsl:when>
			<xsl:when test="$RutFirma ='10940646-5'">DINA ACEVEDO</xsl:when>
			<xsl:when test="$RutFirma ='10898231-4'">MAURICIO CHIANG</xsl:when>
			<xsl:when test="$RutFirma ='10498881-4'">RAUL BELTRAN ASTETE</xsl:when>
			<xsl:when test="$RutFirma ='10404625-8'">CARLOS MONJE VALLEJOS</xsl:when>
			<xsl:when test="$RutFirma ='10191938-2'">RICARDO FONCECA</xsl:when>
			<xsl:when test="$RutFirma ='10073871-6'">NILSON NAVARRO</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'DEBE SOLICITAR CARGA'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
