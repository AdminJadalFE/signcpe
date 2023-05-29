import base64
from django.shortcuts import render
from rest_framework.response import Response
from rest_framework.generics import CreateAPIView
from django.core.files.storage import FileSystemStorage
from werkzeug.utils import secure_filename
from datetime import datetime
import xmltodict
import os
import OpenSSL.crypto
import sys
from lxml import etree as etree
from xml.etree import ElementTree as ET
from signxml import XMLSigner, XMLVerifier, methods
from zipfile import ZipFile
from .serializers import GenerarCPESerializer
from os.path import basename
import qrcode

# Create your views here.


def fnx_TransformarXML(xml_filename, xsl_filename, output):
    p = etree.XMLParser(huge_tree=True)
    xml = etree.parse(xml_filename, parser=p)
    xslt_root = etree.parse(xsl_filename)
    transform = etree.XSLT(xslt_root)
    data_to_sign = None
    try:
        data_to_sign = transform(xml)
        with open(output, 'w', encoding="utf-8") as f:
            f.write(str(data_to_sign))

        return True, data_to_sign
    except:
        errores = ''
        for error in transform.error_log:
            errores = errores + error.message + ' ' + error.line

        return False, errores


class GenerarCPEView(CreateAPIView):
    serializer_class = GenerarCPESerializer

    def post(self, request):
        try:

            if (("xml" in request.FILES) and (request.FILES["xml"])):
                fs = FileSystemStorage()
                xml = request.FILES['xml']
                cpe = xmltodict.parse(xml.read())
                fecha = str(datetime.now().timestamp()).replace('.', '')
                nombreXml = 'asset/cpe/' + \
                    secure_filename(fecha + '-' + xml.name)
                fs.save(nombreXml, xml)

                tipoDocString = ''
                for item in cpe:
                    tipoDocString = item

                # Datos Generales
                nrodocemisor = cpe[tipoDocString]['AccountingSupplierParty']['CustomerAssignedAccountID']
                seriecpe = cpe[tipoDocString]['ID'].split('-')[0]
                numerocpe = cpe[tipoDocString]['ID'].split('-')[1]
                tipocpe = cpe[tipoDocString]['InvoiceTypeCode']

                # Generar UBL
                if tipocpe == '01':
                    xsl_filename = 'asset/ubl/factura.xsl'
                elif tipocpe == '03':
                    xsl_filename = 'asset/ubl/boleta.xsl'
                elif tipocpe == '07':
                    xsl_filename = 'asset/ubl/nc.xsl'

                id = nrodocemisor + '-' + tipocpe + '-' + seriecpe + '-' + numerocpe
                output = 'asset/cpe/' + id + '.xml'

                ind_ubl, stroutput = fnx_TransformarXML(
                    nombreXml, xsl_filename, output)
                if (ind_ubl == False):
                    return Response({
                        'status': False,
                        'content': None,
                        'message': 'Ocurrió  un error al generar el CPE: ' + stroutput
                    }, status=400)

                pfx_path = 'asset/pfx/' + nrodocemisor + '.pfx'
                pkey_path = 'asset/pfx/' + nrodocemisor + '.key'
                pem_path = 'asset/pfx/' + nrodocemisor + '_cert.pem'

                pfx_password = request.data.get('pfx_password')

                print(pfx_password)

                '''
                    Descifrar el archivo P12 (PFX) y crear un archivo de clave privada y un archivo de certificado.
                '''
                print('Abriendo:', pfx_path)
                with open(pfx_path, 'rb') as f_pfx:
                    pfx = f_pfx.read()

                print('Cargando contenido de  P12 (PFX):')
                p12 = OpenSSL.crypto.load_pkcs12(pfx, pfx_password)

                print('Creando archivo .key:', pkey_path)
                with open(pkey_path, 'wb') as f:
                    # Write Private Key
                    f.write(OpenSSL.crypto.dump_privatekey(
                        OpenSSL.crypto.FILETYPE_PEM, p12.get_privatekey()))

                print('Creando archivo .pem:', pem_path)
                with open(pem_path, 'wb') as f:
                    # Write Certificate
                    f.write(OpenSSL.crypto.dump_certificate(
                        OpenSSL.crypto.FILETYPE_PEM, p12.get_certificate()))

                cert, key = [open(f, "rb").read()
                             for f in (pem_path, pkey_path)]

                '''
                    Firmar comprobante electrónico
                '''

                # Carga el documento XML
                doc = etree.parse(output)
                root = doc.getroot()

                # Firmar el documento XML
                signer = XMLSigner(method=methods.enveloped, signature_algorithm="rsa-sha1", digest_algorithm="sha1",
                                   c14n_algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315")
                signed_root = signer.sign(doc, key=key, cert=cert)

                # Verifica la firma
                XMLVerifier().verify(signed_root, x509_cert=cert)

                # Encuentra el elemento Signature y clónalo
                signature = signed_root.find(
                    ".//{http://www.w3.org/2000/09/xmldsig#}Signature")

                # Busca el primer nodo ext:ExtensionContent
                target = root.xpath('//ext:ExtensionContent', namespaces={
                                    'ext': 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2'})[0]

                # Añade la firma a ext:ExtensionContent
                target.append(signature)

                # Guarda el documento firmado
                etree.ElementTree(root).write(
                    output, pretty_print=True, xml_declaration=True, encoding='utf-8')

                '''
                Depurar archivos
                '''
                print("Eliminando archivo XML: " + nombreXml)
                fs.delete(nombreXml)

                # Create a ZipFile Object
                with ZipFile(output.replace('xml', 'zip'), 'w') as zipObj2:
                    zipObj2.write(output, basename(output))

                # Generar Hash

                # xsl_respuesta = 'asset/etc/respuesta.xsl'
                # outputhash = 'asset/hash/' + nrodocemisor + '-' + \
                #     tipocpe + '-' + seriecpe + '-' + numerocpe + '.xml'

                # ind_hash, stroutputhash = fnx_TransformarXML(
                #     output, xsl_respuesta, outputhash)
                # if (ind_hash == False):
                #     return Response({
                #         'status': False,
                #         'content': None,
                #         'message': 'Ocurrió  un error al generar el Hash: ' + stroutputhash
                #     }, status=400)

                # hash = xmltodict.parse(stroutputhash)
                # valorhash = hash['Respuesta']['Hash']
                # print(valorhash)

                # qr = qrcode.QRCode(
                #     version=1,
                #     error_correction=qrcode.constants.ERROR_CORRECT_L,
                #     box_size=10,
                #     border=4,
                # )
                # qr.add_data(valorhash)
                # qr.make(fit=True)
                # img = qr.make_image(fill_color="black", back_color="white")
                # img.save(outputhash.replace('xml', 'jpg'))

                with open(output.replace('xml', 'zip'), 'rb') as file:
                    zip_data = file.read()
                    base64_data = base64.b64encode(zip_data).decode('utf-8')

                print("Eliminando archivo UBL: " + output)
                fs.delete(output)
                fs.delete(output.replace('xml', 'zip'))
                # fs.delete(outputhash)

                return Response({
                    'status': True,
                    'message': id,
                    'content': base64_data
                }, status=200)

            else:
                return Response({
                    'status': False,
                    'message': 'No se envió el XML del CPE',
                    'content': None
                }, status=400)
        except Exception as error:
            return Response({
                'status': False,
                'message': 'Ocurrió un error en el registro: {0}'.format(error),
                'content': None
            }, status=400)
