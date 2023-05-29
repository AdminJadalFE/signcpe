<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
		xmlns:func="http://exslt.org/functions" 
		xmlns:date="http://exslt.org/dates-and-times" 
		xmlns:str="http://exslt.org/strings" 
		xmlns:exsl="http://exslt.org/common" 
		xmlns:msxsl="urn:schemas-microsoft-com:xslt"
		xmlns:local="urn:local"		
		xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
		extension-element-prefixes="xsl func date str exsl msxsl local soapenv">
	<xsl:output method="xml" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="no" standalone="yes" indent="yes"/>

	<!-- ==============================  Variables Globales ========================================= --> 
	<xsl:variable name="TpoCPE" select="normalize-space(/Invoice/InvoiceTypeCode)"/>
	<xsl:variable name="Folio" select="normalize-space(/Invoice/ID)"/>
	<xsl:variable name="FechaEmision" select="normalize-space(/Invoice/IssueDate)"/>
	<xsl:variable name="CodigoMoneda" select="normalize-space(/Invoice/DocumentCurrencyCode)"/> 
	<xsl:variable name="FechaVencimiento" select="normalize-space(/Invoice/DueDate)"/>
	<xsl:variable name="HoraEmision" select="normalize-space(/Invoice/IssueTime)"/>
	<xsl:variable name="CodigoTipoOperacion" select="normalize-space(/Invoice/ProfileID)"/>
	<xsl:variable name="SignatureID" select="concat('SigNode-', $TpoCPE, '-', $Folio)"/> 
	      
	<!-- ==============================  Datos Emisor ========================================= --> 
	<xsl:variable name="NroDocEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/CustomerAssignedAccountID)"/>
	<xsl:variable name="TipoDocEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/AdditionalAccountID)"/>
	<xsl:variable name="RazonSocialEmisor" select="substring(normalize-space(/Invoice/AccountingSupplierParty/Party/PartyLegalEntity/RegistrationName), 1, 1500)"/>
	<xsl:variable name="NombreComercialEmisor" select="substring(normalize-space(/Invoice/AccountingSupplierParty/Party/PartyName/Name), 1, 1500)"/>
	<xsl:variable name="UbigeoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/ID)"/>
	<xsl:variable name="DireccionEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/StreetName)"/>
	<xsl:variable name="UrbanizacionEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/CitySubdivisionName)"/>
	<xsl:variable name="ProvinciaEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/CityName)"/>
	<xsl:variable name="DepartamentoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/CountrySubentity)"/>
	<xsl:variable name="DistritoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/District)"/>
	<xsl:variable name="CodigoPaisEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/Country/IdentificationCode)"/>
	<xsl:variable name="PaginaWebEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/WebsiteURI)"/>
	<xsl:variable name="TelefonoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/Telephone)"/>
	<xsl:variable name="CorreoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/ElectronicMail)"/>
	<xsl:variable name="CodigoEstablecimientoEmisor" select="normalize-space(/Invoice/AccountingSupplierParty/Party/AddressTypeCode)"/>
	 
	<!-- ==============================  Datos Receptor ========================================= -->  
	<xsl:variable name="NroDocReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/CustomerAssignedAccountID)"/>
	<xsl:variable name="TipoDocReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/AdditionalAccountID)"/>
	<xsl:variable name="RazonSocialReceptor" select="substring(normalize-space(/Invoice/AccountingCustomerParty/Party/PartyLegalEntity/RegistrationName), 1, 1500)"/>
	<xsl:variable name="NombreComercialReceptor" select="substring(normalize-space(/Invoice/AccountingCustomerParty/Party/PartyName/Name), 1, 1500)"/>
	<xsl:variable name="UbigeoReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/ID)"/>
	<xsl:variable name="DireccionReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/StreetName)"/>
	<xsl:variable name="UrbanizacionReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/CitySubdivisionName)"/>
	<xsl:variable name="ProvinciaReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/CityName)"/>
	<xsl:variable name="DepartamentoReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/CountrySubentity)"/>
	<xsl:variable name="DistritoReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/District)"/>
	<xsl:variable name="CodigoPaisReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/Country/IdentificationCode)"/> 
	<xsl:variable name="CodigoEstablecimientoReceptor" select="normalize-space(/Invoice/AccountingCustomerParty/Party/AddressTypeCode)"/>
	<!-- ==============================  TotalCPE ========================================= --> 
	<xsl:variable name="SubTotal" select="normalize-space(/Invoice/LegalMonetaryTotal/LineExtensionAmount)"/>
	<xsl:variable name="TotalPrecioVenta" select="normalize-space(/Invoice/LegalMonetaryTotal/TaxInclusiveAmount)"/>
	<xsl:variable name="TotalDescuentos" select="normalize-space(/Invoice/LegalMonetaryTotal/AllowanceTotalAmount)"/>
	<xsl:variable name="TotalCargos" select="normalize-space(/Invoice/LegalMonetaryTotal/ChargeTotalAmount)"/>
	<xsl:variable name="TotalAnticipos" select="normalize-space(/Invoice/LegalMonetaryTotal/PrepaidAmount)"/>
	<xsl:variable name="ImporteTotalVenta" select="normalize-space(/Invoice/LegalMonetaryTotal/PayableAmount)"/>
	<xsl:variable name="ImporteRedondeo" select="normalize-space(/Invoice/LegalMonetaryTotal/PayableRoundingAmount)"/> 
	
	<!-- ==============================  Documento Tributario Electronico  ============================ -->
	<!-- ======================================================================================== -->
	<xsl:variable name="CPE">
		<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
			xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
			xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
			xmlns:ccts="urn:un:unece:uncefact:documentation:2"
			xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
			xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"
			xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xmlns:exsl="http://exslt.org/common" 
			xmlns:ds="http://www.w3.org/2000/09/xmldsig#" 
			xmlns:jadal="http://tempuri.org/">  
			<ext:UBLExtensions>
				<ext:UBLExtension>
					<ext:ExtensionContent></ext:ExtensionContent>
				</ext:UBLExtension>
				<ext:UBLExtension>
					<ext:ExtensionContent>
						<jadal:AdditionalInformationJadal> 
							<jadal:Proveedor>Click Data Service</jadal:Proveedor>
							<jadal:Version>1.0.0.0</jadal:Version> 
						</jadal:AdditionalInformationJadal>
					</ext:ExtensionContent>
				</ext:UBLExtension>
				<ext:UBLExtension>
					<ext:ExtensionContent>
						<jadal:AdditionalInformationCliente> 
							<xsl:if test="normalize-space(/Invoice/Adjuntos/Observacion) != ''">
								<jadal:Observacion><xsl:value-of select="normalize-space(/Invoice/Adjuntos/Observacion)"/></jadal:Observacion>
							</xsl:if>	    	
						</jadal:AdditionalInformationCliente>
					</ext:ExtensionContent>
				</ext:UBLExtension>
			</ext:UBLExtensions> 

			<!-- datos del cpe -->
			<cbc:UBLVersionID>2.1</cbc:UBLVersionID>
			<cbc:CustomizationID schemeAgencyName="PE:SUNAT">2.0</cbc:CustomizationID>    
			<!-- Folio del comprobante --> 
			<cbc:ID><xsl:value-of select="$Folio"/></cbc:ID>
			<!-- Fecha de emision del comprobante --> 
			<cbc:IssueDate> <xsl:value-of select="$FechaEmision"/></cbc:IssueDate>
			<!-- Hora de emision del comprobante --> 
			<xsl:if test="$HoraEmision != ''">
				<cbc:IssueTime><xsl:value-of select="$HoraEmision"/></cbc:IssueTime>
			</xsl:if>
			<!-- Fecha de vencimiento del comprobante --> 
			<xsl:if test="$FechaVencimiento != ''">
				<cbc:DueDate><xsl:value-of select="normalize-space($FechaVencimiento)"/></cbc:DueDate>
			</xsl:if>		
			<!-- Codigo tipo de operacion SUNAT - catalogo 51 / Codigo tipo de comprobante - catalogo 01 -->  
			<cbc:InvoiceTypeCode listID="{$CodigoTipoOperacion}" listName="Tipo de Documento" listAgencyName="PE:SUNAT" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo01">
				<xsl:value-of select="$TpoCPE"/>
			</cbc:InvoiceTypeCode> 
			 
			<!-- Notas asociadas al comprobante - catalogo 52 --> 
 
			<xsl:for-each select="/Invoice/AdditionalInformation/AdditionalProperty">
				<xsl:variable name="note" select="ID"/>
				<cbc:Note languageLocaleID="{$note}"><xsl:value-of select="Value"/></cbc:Note> 
			</xsl:for-each> 
			
			<!-- Codigo tipo de CodigoMoneda - catalogo 01 -->  
			<cbc:DocumentCurrencyCode listID="ISO 4217 Alpha" listAgencyName="United Nations Economic Commission for Europe" listName="Currency">
				<xsl:value-of select="$CodigoMoneda" />
			</cbc:DocumentCurrencyCode> 
			 
			<!-- Orden de compra -->
			<xsl:if test="/Invoice/OrderReference/ID != ''">
				<cac:OrderReference>
					<cbc:ID><xsl:value-of select="substring(normalize-space(/Invoice/OrderReference/ID), 1, 20)" /></cbc:ID>
				</cac:OrderReference>
			</xsl:if>
			<!-- Guia de remision -->
			<xsl:if test="/Invoice/DespatchDocumentReference/ID != '' and /Invoice/DespatchDocumentReference/DocumentTypeCode != ''">
				<cac:DespatchDocumentReference>
					<cbc:ID><xsl:value-of select="normalize-space(/Invoice/DespatchDocumentReference/ID)" /></cbc:ID>
					<cbc:DocumentTypeCode listAgencyName="PE:SUNAT" listName="Tipo de Documento" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo01">
						<xsl:value-of select="normalize-space(/Invoice/DespatchDocumentReference/DocumentTypeCode)" />
					</cbc:DocumentTypeCode>
				</cac:DespatchDocumentReference>
			</xsl:if>
			<!-- Otro documento asociado -->
			<xsl:if test="/Invoice/AdditionalDocumentReference/ID != '' and /Invoice/AdditionalDocumentReference/DocumentTypeCode != ''">
				<cac:AdditionalDocumentReference>
					<cbc:ID><xsl:value-of select="normalize-space(/Invoice/AdditionalDocumentReference/ID)"/></cbc:ID>
					<cbc:DocumentTypeCode listAgencyName="PE:SUNAT" listName="Documento Relacionado" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo12">
						<xsl:value-of select="normalize-space(/Invoice/AdditionalDocumentReference/DocumentTypeCode)" />
					</cbc:DocumentTypeCode> 
				</cac:AdditionalDocumentReference>
			</xsl:if>
			
			<!-- INCRUSTA FIRMA -->
			<cac:Signature>
				<cbc:ID>SignatureID</cbc:ID>
				<cac:SignatoryParty>
					<cac:PartyIdentification><cbc:ID><xsl:value-of select="$NroDocEmisor"/></cbc:ID>
					</cac:PartyIdentification>
					<cac:PartyName><cbc:Name><xsl:value-of select="$RazonSocialEmisor"/></cbc:Name>
					</cac:PartyName>
					<cac:AgentParty>
						<cac:PartyIdentification><cbc:ID><xsl:value-of select="$NroDocEmisor"/></cbc:ID></cac:PartyIdentification>
						<cac:PartyLegalEntity><cbc:RegistrationName><xsl:value-of select="$RazonSocialEmisor"/></cbc:RegistrationName></cac:PartyLegalEntity>
					</cac:AgentParty>
				</cac:SignatoryParty>
				<cac:DigitalSignatureAttachment>
					<cac:ExternalReference><cbc:URI><xsl:value-of select="$SignatureID"/></cbc:URI></cac:ExternalReference>
				</cac:DigitalSignatureAttachment>
			</cac:Signature>
			
			<!-- Emisor -->
			<cac:AccountingSupplierParty> 
				<cac:Party> 
					<xsl:if test="$PaginaWebEmisor != ''">
						<cbc:WebsiteURI> 
							<xsl:value-of select="$PaginaWebEmisor" />
						</cbc:WebsiteURI>
					</xsl:if>
					<cac:PartyIdentification>
						<cbc:ID schemeID="{$TipoDocEmisor}" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06"><xsl:value-of select="$NroDocEmisor"/></cbc:ID>
					</cac:PartyIdentification>
					<xsl:if test="$NombreComercialEmisor != ''">
						<cac:PartyName>
							<cbc:Name><xsl:value-of select="$NombreComercialEmisor"/></cbc:Name>
						</cac:PartyName>  
					</xsl:if>   
					<cac:PartyLegalEntity>
						<cbc:RegistrationName><xsl:value-of select="$RazonSocialEmisor"/></cbc:RegistrationName>
						<cac:RegistrationAddress>
							<xsl:if test="$UbigeoEmisor != ''">
								<cbc:ID><xsl:value-of select="$UbigeoEmisor"/></cbc:ID>
							</xsl:if>
							<xsl:if test="$CodigoEstablecimientoEmisor != ''">
								<cbc:AddressTypeCode><xsl:value-of select="$CodigoEstablecimientoEmisor"/></cbc:AddressTypeCode>
							</xsl:if>
							<xsl:if test="$DireccionEmisor != ''">
								<cbc:StreetName><xsl:value-of select="$DireccionEmisor"/></cbc:StreetName>
							</xsl:if>
							<xsl:if test="$UrbanizacionEmisor != ''">
								<cbc:CitySubdivisionName><xsl:value-of select="$UrbanizacionEmisor" /></cbc:CitySubdivisionName>
							</xsl:if>
							<xsl:if test="$ProvinciaEmisor != ''">
								<cbc:CityName><xsl:value-of select="$ProvinciaEmisor"/></cbc:CityName>
							</xsl:if>
							<xsl:if test="$DepartamentoEmisor != ''">
								<cbc:CountrySubentity><xsl:value-of select="$DepartamentoEmisor"/></cbc:CountrySubentity>
							</xsl:if>
							<xsl:if test="$DistritoEmisor != ''">
								<cbc:District><xsl:value-of select="$DistritoEmisor"/></cbc:District>
							</xsl:if>
							<xsl:if test="$CodigoPaisEmisor != ''">
								<cac:Country>
									<cbc:IdentificationCode listID="ISO 3166-1" listAgencyID="United Nations Economic Commission for Europe" listName="Country">
										<xsl:value-of select="$CodigoPaisEmisor" />
									</cbc:IdentificationCode>
								</cac:Country>
							</xsl:if> 
						</cac:RegistrationAddress>
					</cac:PartyLegalEntity>   
					<xsl:if test="$TelefonoEmisor != '' or $CorreoEmisor != ''">
						<cac:Contact>
							<xsl:if test="$TelefonoEmisor != ''">
								<cbc:Telephone><xsl:value-of select="$TelefonoEmisor" /></cbc:Telephone> 
							</xsl:if> 
							<xsl:if test="$CorreoEmisor != ''">
								<cbc:ElectronicMail><xsl:value-of select="$CorreoEmisor" /></cbc:ElectronicMail>
							</xsl:if>
						</cac:Contact>
					</xsl:if> 
				</cac:Party> 
			</cac:AccountingSupplierParty>
			<!-- Receptor -->
			<cac:AccountingCustomerParty> 
				<cac:Party> 
					<cac:PartyIdentification>
						<cbc:ID schemeID="{$TipoDocReceptor}" schemeName="Documento de Identidad" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo06"><xsl:value-of select="$NroDocReceptor"/></cbc:ID>
					</cac:PartyIdentification>
					<xsl:if test="$NombreComercialReceptor != ''">
						<cac:PartyName>
							<cbc:Name><xsl:value-of select="$NombreComercialReceptor"/></cbc:Name>
						</cac:PartyName>  
					</xsl:if> 
					<cac:PartyLegalEntity>
						<cbc:RegistrationName><xsl:value-of select="$RazonSocialReceptor"/></cbc:RegistrationName>
						<cac:RegistrationAddress>
							<xsl:if test="$UbigeoReceptor != ''">
								<cbc:ID><xsl:value-of select="$UbigeoReceptor"/></cbc:ID>
							</xsl:if>
							<xsl:if test="$CodigoEstablecimientoReceptor != ''">
								<cbc:AddressTypeCode><xsl:value-of select="$CodigoEstablecimientoReceptor"/></cbc:AddressTypeCode>
							</xsl:if>
							<xsl:if test="$DireccionReceptor != ''">
								<cbc:StreetName><xsl:value-of select="$DireccionReceptor"/></cbc:StreetName>
							</xsl:if>
							<xsl:if test="$UrbanizacionReceptor != ''">
								<cbc:CitySubdivisionName><xsl:value-of select="$UrbanizacionReceptor" /></cbc:CitySubdivisionName>
							</xsl:if>
							<xsl:if test="$ProvinciaReceptor != ''">
								<cbc:CityName><xsl:value-of select="$ProvinciaReceptor"/></cbc:CityName>
							</xsl:if>
							<xsl:if test="$DepartamentoReceptor != ''">
								<cbc:CountrySubentity><xsl:value-of select="$DepartamentoReceptor"/></cbc:CountrySubentity>
							</xsl:if>
							<xsl:if test="$DistritoReceptor != ''">
								<cbc:District><xsl:value-of select="$DistritoReceptor"/></cbc:District>
							</xsl:if>
							<xsl:if test="$CodigoPaisReceptor != ''">
								<cac:Country>
									<cbc:IdentificationCode listID="ISO 3166-1" listAgencyID="United Nations Economic Commission for Europe" listName="Country">
										<xsl:value-of select="$CodigoPaisReceptor" />
									</cbc:IdentificationCode>
								</cac:Country>
							</xsl:if> 
						</cac:RegistrationAddress>
					</cac:PartyLegalEntity>    
				</cac:Party>  
			</cac:AccountingCustomerParty> 
	  
			
			<!-- DATOS DE LA CUENTA DEL BANCO DE LA NACION - DETRACCI�N -->
			<xsl:if test="/Invoice/PaymentMeans/ID != ''">
				<cac:PaymentMeans> 
					<!-- Correlativo -->
					<cbc:ID><xsl:value-of select="normalize-space(/Invoice/PaymentMeans/ID)"/></cbc:ID>
					<!-- Forma de pago - catalogo 59 -->
					<cbc:PaymentMeansCode><xsl:value-of select="normalize-space(/Invoice/PaymentMeans/PaymentMeansCode)"/></cbc:PaymentMeansCode>
					<cac:PayeeFinancialAccount>
						<cbc:ID><xsl:value-of select="normalize-space(/Invoice/PaymentMeans/PayeeFinancialAccount/ID)"/></cbc:ID>
					</cac:PayeeFinancialAccount> 
				</cac:PaymentMeans>
			</xsl:if>
			
			<!-- DATOS DE LA DETRACCI�N - DETRACCI�N -->
			<xsl:if test="/Invoice/PaymentTerms/PaymentMeansID != '' and  (PaymentMeansID = 'Contado' or PaymentMeansID = 'Credito')">
				<cac:PaymentTerms>
					<xsl:variable name="tman" select="/Invoice/PaymentTerms/CurrencyID"/> 
					<cbc:PaymentMeansID schemeName="Codigo de detraccion" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo54">
						<xsl:value-of select="normalize-space(/Invoice/PaymentTerms/PaymentMeansID)"/>
					</cbc:PaymentMeansID>
					<cbc:PaymentPercent>
						<xsl:value-of select="normalize-space(/Invoice/PaymentTerms/PaymentPercent)"/>
					</cbc:PaymentPercent>
					<cbc:Amount currencyID="{$tman}">
						<xsl:value-of select="normalize-space(/Invoice/PaymentTerms/Amount)"/>
					</cbc:Amount>
				</cac:PaymentTerms>
			</xsl:if>
			
			<!-- DATOS DE LA FORMA DE PAGO -->
			<xsl:for-each select="/Invoice/PaymentTerms">
				<xsl:if test="PaymentMeansID = 'Contado' or Amount != ''">
					<cac:PaymentTerms>
						<cbc:ID>FormaPago</cbc:ID>
						<cbc:PaymentMeansID>
							<xsl:value-of select="normalize-space(PaymentMeansID)"/>
						</cbc:PaymentMeansID>
						<xsl:if test= "Amount!=''">
							<cbc:Amount currencyID="{$CodigoMoneda}"><xsl:value-of select="Amount"/></cbc:Amount>
						</xsl:if> 
					</cac:PaymentTerms>
				</xsl:if>
			</xsl:for-each>

			<!-- DATOS DE LOS COMPROBANTES DE ANTICIPO -->
			<xsl:for-each select="/Invoice/PrepaidPayment">	
				<xsl:if test="ID != ''"> 
					<xsl:variable name="tdan" select="DocumentTypeCode"/> 
					<xsl:variable name="tman" select="CurrencyID"/> 
					<cac:PrepaidPayment>
						<cbc:ID schemeID="{$tdan}" schemeName="Anticipo" schemeAgencyName="PE:SUNAT">
							<xsl:value-of select="normalize-space(ID)"/>
						</cbc:ID>
						<cbc:PaidAmount currencyID="{$tman}">
							<xsl:value-of select="normalize-space(PaidAmount)"/>
						</cbc:PaidAmount>
						<xsl:if test="Payment/PaidDate != ''">
							<cbc:PaidDate>
								<xsl:value-of select="normalize-space(Payment/PaidDate)"/>
							</cbc:PaidDate>
						</xsl:if> 
						<cbc:InstructionID schemeID="{$TipoDocEmisor}">
							<xsl:value-of select="$NroDocEmisor"/>
						</cbc:InstructionID>
					</cac:PrepaidPayment>
				</xsl:if>
			</xsl:for-each>
			
			<!-- DESCUENTOS / CARGOS -->
			<xsl:for-each select="/Invoice/AllowanceCharge">	
				<xsl:if test="ChargeIndicator != ''">
					<cac:AllowanceCharge>
						<cbc:ChargeIndicator>
							<xsl:value-of select="normalize-space(ChargeIndicator)"/>
						</cbc:ChargeIndicator>
						<cbc:AllowanceChargeReasonCode listAgencyName="PE:SUNAT" listName="Cargo/descuento" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo53">
							<xsl:value-of select="normalize-space(AllowanceChargeReasonCode)"/>
						</cbc:AllowanceChargeReasonCode>
						<cbc:MultiplierFactorNumeric>
							<xsl:value-of select="normalize-space(MultiplierFactorNumeric)"/>
						</cbc:MultiplierFactorNumeric>
						<cbc:Amount currencyID="{$CodigoMoneda}">
							<xsl:value-of select="normalize-space(Amount)" />
						</cbc:Amount>
						<cbc:BaseAmount currencyID="{$CodigoMoneda}">
							<xsl:value-of select="normalize-space(BaseAmount)"/>
						</cbc:BaseAmount>
					</cac:AllowanceCharge>
				</xsl:if>	
			</xsl:for-each> 
			
			<!-- TOTALES E IMPUESTOS -->	 	
			<cac:TaxTotal>
				<cbc:TaxAmount currencyID="{$CodigoMoneda}">
					<xsl:value-of select="normalize-space(/Invoice/LegalMonetaryTotal/TaxAmount)"/>
				</cbc:TaxAmount>
				<xsl:for-each select="/Invoice/TaxTotal">	
					<cac:TaxSubtotal>
						<xsl:if test="TaxSubtotal/TaxableAmount != '' and TaxSubtotal/TaxableAmount != '0' and TaxSubtotal/TaxableAmount != '0.00'">
							<cbc:TaxableAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="normalize-space(TaxSubtotal/TaxableAmount)"/></cbc:TaxableAmount>
						</xsl:if>
						<xsl:if test="TaxSubtotal/TaxAmount != ''">
							<cbc:TaxAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="normalize-space(TaxSubtotal/TaxAmount)"/></cbc:TaxAmount>
						</xsl:if>
						<cac:TaxCategory> 
							<cbc:ID schemeID="UN/ECE 5305"  schemeName="Tax Category Identifier" schemeAgencyName="United Nations Economic Commission for Europe">
								<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/ID)"/>
							</cbc:ID>
							<cac:TaxScheme>
								<cbc:ID schemeName="Codigo de tributos" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo05">
									<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/TaxScheme/ID)"/>
								</cbc:ID>
								<cbc:Name>
									<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/TaxScheme/Name)"/>
								</cbc:Name>
								<cbc:TaxTypeCode>
									<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/TaxScheme/TaxTypeCode)"/>
								</cbc:TaxTypeCode>
							</cac:TaxScheme>
						</cac:TaxCategory>
					</cac:TaxSubtotal>
				</xsl:for-each>
			</cac:TaxTotal> 
			
			<!-- MONTOS TOTALES -->
			<cac:LegalMonetaryTotal> 
				<!-- Total precio de venta (NO incluye impuestos) -->
				<xsl:if test="$SubTotal != '' and $SubTotal != '0' and $SubTotal != '0.00'">
					<cbc:LineExtensionAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$SubTotal"/></cbc:LineExtensionAmount>
				</xsl:if>
				<!-- Total precio de venta (incluye impuestos) -->
				<xsl:if test="$TotalPrecioVenta != '' and $TotalPrecioVenta != '0' and $TotalPrecioVenta != '0.00'">
					<cbc:TaxInclusiveAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$TotalPrecioVenta"/></cbc:TaxInclusiveAmount>
				</xsl:if>
				<!-- Descuentos globales -->
				<xsl:if test="$TotalDescuentos != '' and $TotalDescuentos != '0' and $TotalDescuentos != '0.00'">
					<cbc:AllowanceTotalAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$TotalDescuentos"/></cbc:AllowanceTotalAmount>
				</xsl:if>
				<!-- Sumatoria otros cargos -->
				<xsl:if test="$TotalCargos != '' and $TotalCargos != '0' and $TotalCargos != '0.00'">
					<cbc:ChargeTotalAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$TotalCargos" /></cbc:ChargeTotalAmount>
				</xsl:if>
				<!-- Total Anticipo--> 
				<xsl:if test="$TotalAnticipos != '' and $TotalAnticipos != '0' and $TotalAnticipos != '0.00'">
					<cbc:PrepaidAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$TotalAnticipos" /></cbc:PrepaidAmount>
				</xsl:if>
				<!-- Redondeo -->
				<xsl:if test="$ImporteRedondeo != '' and $ImporteRedondeo != '0' and $ImporteRedondeo != '0.00'">
					<cbc:PayableRoundingAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$ImporteRedondeo" /></cbc:PayableRoundingAmount>
				</xsl:if> 
				<!-- Total -->
				<cbc:PayableAmount currencyID="{$CodigoMoneda}"><xsl:value-of select="$ImporteTotalVenta" /></cbc:PayableAmount>
			</cac:LegalMonetaryTotal>
			
			<!-- Detalle -->
			<xsl:for-each select="/Invoice/InvoiceLine"> 
				<xsl:variable name="det" select="UnitCode"/> 
				<cac:InvoiceLine>
					<cbc:ID>
						<xsl:value-of select="position()" />
					</cbc:ID>
					<cbc:InvoicedQuantity unitCode="{$det}" unitCodeListID="UN/ECE rec 20" unitCodeListAgencyName="United Nations Economic Commission for Europe">
						<xsl:value-of select="InvoicedQuantity" />
					</cbc:InvoicedQuantity>
					<cbc:LineExtensionAmount currencyID="{$CodigoMoneda}">
						<xsl:value-of select="normalize-space(LineExtensionAmount)" />
					</cbc:LineExtensionAmount>
					<cac:PricingReference>
						<xsl:for-each select="PricingReference/AlternativeConditionPrice">
							<cac:AlternativeConditionPrice>
								<cbc:PriceAmount currencyID="{$CodigoMoneda}">
									<xsl:value-of select="normalize-space(PriceAmount)" />
								</cbc:PriceAmount>
								<cbc:PriceTypeCode listName="Tipo de Precio" listAgencyName="PE:SUNAT" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo16">
									<xsl:value-of select="normalize-space(PriceTypeCode)" />
								</cbc:PriceTypeCode>
							</cac:AlternativeConditionPrice>
						</xsl:for-each>
					</cac:PricingReference>
					<!-- Descuento por item -->  
					<xsl:for-each select="AllowanceCharge">	
						<xsl:if test="ChargeIndicator != ''">
							<cac:AllowanceCharge>
								<cbc:ChargeIndicator>
									<xsl:value-of select="normalize-space(ChargeIndicator)"/>
								</cbc:ChargeIndicator>
								<cbc:AllowanceChargeReasonCode listAgencyName="PE:SUNAT" listName="Cargo/descuento" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo53">
									<xsl:value-of select="normalize-space(AllowanceChargeReasonCode)"/>
								</cbc:AllowanceChargeReasonCode>
								<cbc:MultiplierFactorNumeric>
									<xsl:value-of select="normalize-space(MultiplierFactorNumeric)"/>
								</cbc:MultiplierFactorNumeric>
								<cbc:Amount currencyID="{$CodigoMoneda}">
									<xsl:value-of select="normalize-space(Amount)" />
								</cbc:Amount>
								<cbc:BaseAmount currencyID="{$CodigoMoneda}">
									<xsl:value-of select="normalize-space(BaseAmount)"/>
								</cbc:BaseAmount>
							</cac:AllowanceCharge>
						</xsl:if>	
					</xsl:for-each>  
					<!-- Impuestos - por - item -->  
					<cac:TaxTotal>
						<cbc:TaxAmount currencyID="{$CodigoMoneda}">
							<xsl:value-of select="normalize-space(TaxAmount)" />
						</cbc:TaxAmount>
						<xsl:for-each select="TaxTotal">	
							<cac:TaxSubtotal>
								<cbc:TaxableAmount currencyID="{$CodigoMoneda}">
									<xsl:value-of select="normalize-space(TaxSubtotal/TaxableAmount)" />
								</cbc:TaxableAmount>
								<cbc:TaxAmount currencyID="{$CodigoMoneda}">
									<xsl:value-of select="normalize-space(TaxSubtotal/TaxAmount)" />
								</cbc:TaxAmount>
								<cac:TaxCategory> 
									<cbc:ID schemeID="UN/ECE 5305"  schemeName="Tax Category Identifier" schemeAgencyName="United Nations Economic Commission for Europe">
										<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/ID)"/>
									</cbc:ID>
									<xsl:if test="TaxSubtotal/TaxCategory/Percent != ''">
										<cbc:Percent>
											<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/Percent)" />
										</cbc:Percent>
									</xsl:if>
									<xsl:if test="TaxSubtotal/TaxCategory/TaxExemptionReasonCode != ''">
										<cbc:TaxExemptionReasonCode listAgencyName="PE:SUNAT" listName="Afectacion del IGV" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo07">
											<xsl:value-of select="normalize-space(TaxSubtotal/TaxCategory/TaxExemptionReasonCode)" />
										</cbc:TaxExemptionReasonCode>	
									</xsl:if>
									<xsl:if test="TaxSubtotal/TaxCategory/TierRange != ''">
										<cbc:TierRange>
											<xsl:value-of select="TaxSubtotal/TaxCategory/TierRange"/>
										</cbc:TierRange>
									</xsl:if>
									<cac:TaxScheme>
										<cbc:ID schemeName="Codigo de tributos" schemeAgencyName="PE:SUNAT" schemeURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo05">
											<xsl:value-of select="TaxSubtotal/TaxCategory/TaxScheme/ID" />
										</cbc:ID>
										<cbc:Name><xsl:value-of select="TaxSubtotal/TaxCategory/TaxScheme/Name"/></cbc:Name>
										<cbc:TaxTypeCode><xsl:value-of select="TaxSubtotal/TaxCategory/TaxScheme/TaxTypeCode"/></cbc:TaxTypeCode>
									</cac:TaxScheme>
								</cac:TaxCategory>
							</cac:TaxSubtotal>
						</xsl:for-each>
					</cac:TaxTotal> 
					<xsl:for-each select="Item">
						<cac:Item>
							<xsl:for-each select="Description">
								<xsl:if test="text() != ''">
									<cbc:Description><xsl:value-of select="text()" /></cbc:Description>
								</xsl:if>
							</xsl:for-each>	 
							<xsl:if test="AdditionalInformation != ''">
								<cbc:Description><xsl:value-of select="AdditionalInformation" /></cbc:Description>
							</xsl:if>
							<xsl:if test="SellersItemIdentification/ID != ''">
								<cac:SellersItemIdentification>
									<cbc:ID>
										<xsl:value-of select="substring(normalize-space(SellersItemIdentification/ID), 1, 30)" />
									</cbc:ID>
								</cac:SellersItemIdentification>
							</xsl:if>
							<xsl:if test="StandardItemIdentification/ID != ''">
								<cac:StandardItemIdentification>
								   <cbc:ID schemeID="GTIN">
										<xsl:value-of select="substring(normalize-space(StandardItemIdentification/ID), 1, 14)" />
								   </cbc:ID>
								</cac:StandardItemIdentification>
							</xsl:if>
							<xsl:if test="CommodityClassification/ItemClassificationCode != ''">
								<cac:CommodityClassification>
									<cbc:ItemClassificationCode listID="UNSPSC" listAgencyName="GS1 US" listName="Item Classification">
										<xsl:value-of select="substring(normalize-space(CommodityClassification/ItemClassificationCode), 1, 8)" />
									</cbc:ItemClassificationCode>
								</cac:CommodityClassification>
							</xsl:if>
							<xsl:if test="AdditionalItemProperty/Name != ''">
								<cac:AdditionalItemProperty>
									<cbc:Name>
										<xsl:value-of select="substring(normalize-space(AdditionalItemProperty/Name), 1, 100)" />
									</cbc:Name>
									<cbc:NameCode listName="Propiedad del item" listAgencyName="PE:SUNAT" listURI="urn:pe:gob:sunat:cpe:see:gem:catalogos:catalogo55">
										<xsl:value-of select="AdditionalItemProperty/NameCode" />
									</cbc:NameCode>
									<cbc:Value>
										<xsl:value-of select="AdditionalItemProperty/Value"/>
									</cbc:Value>
									<cbc:ValueQuantity unitCode="TNE" unitCodeListID="UN/ECE rec 20" unitCodeListAgencyName="United Nations Economic Commission for Europe">
										<xsl:value-of select="AdditionalItemProperty/ValueQuantity" />
									</cbc:ValueQuantity> 
								</cac:AdditionalItemProperty>
							</xsl:if>
						</cac:Item>
					</xsl:for-each>
					<cac:Price>
						<cbc:PriceAmount currencyID="{$CodigoMoneda}">
							<xsl:value-of select="normalize-space(Price/PriceAmount)" />
						</cbc:PriceAmount>
					</cac:Price>
				</cac:InvoiceLine>
			</xsl:for-each>
		</Invoice> 
	</xsl:variable>
 
	<!-- ================================================================================ -->
	<!-- ============================== TEMPLATE PRINCIPAL ============================== -->
	<!-- ================================================================================ -->
	<xsl:template match="/">	
		<xsl:copy-of select="$CPE"/>
	</xsl:template>
</xsl:stylesheet>