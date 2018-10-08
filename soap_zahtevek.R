p_load(RCurl)

body <- '<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body>
    <PrsDataFind xmlns="http://www.ajpes.si/wsPrs/PrsInfo">
      <sNaziv>ajpes</sNaziv>
      <sMaticna/>
      <sDavcna/>
      <sNaslov/>
      <sHisnaStevilka/>
      <sNaselje/>
      <sObcina/>
      <sPosta>1000</sPosta>
      <sDejavnost/>
      <sSektor/>
      <sOblika/>
      <iTip>0</iTip>
      <iMaxRec>20</iMaxRec>
      <Ident>
        <string>wsPrsInfoTest</string>
        <string>geslo*1</string>
        <string>PRS_MN_E</string>
      </Ident>
    </PrsDataFind>
  </soap:Body>
</soap:Envelope>'
