xquery version "1.0";
 
import module namespace 
   lib-util="http://www.cagrid.org/xquery/library/util" 
   at "../library/m-lib-util.xquery";
   
import module namespace 
    lib-forms="http://www.cagrid.org/xquery/library/forms" 
    at "../edit/m-lib-forms.xquery";     
    
import module namespace 
    lib-make-admin-item="http://www.cagrid.org/xquery/library/make-admin-item" 
    at "../edit/m-lib-make-admin-item.xquery";      
    
import module namespace 
   lib-supersede="http://www.cagrid.org/xquery/library/supersede"
   at "../edit/m-lib-supersede.xquery";
   
import module namespace 
   administered-item="http://www.cagrid.org/xquery/library/administered-item" 
   at "../library/m-administered-item.xquery";    
   
declare namespace openMDR = "http://www.cagrid.org/schema/openMDR";
declare namespace ISO11179= "http://www.cagrid.org/schema/ISO11179";  
declare namespace request="http://exist-db.org/xquery/request";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace response="http://exist-db.org/xquery/response";
declare namespace validation="http://exist-db.org/xquery/validation";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace datetime = "http://exist-db.org/xquery/datetime";

(: wizard pages :)

declare function local:page-button($button-text as xs:string) as element(input)
{
   <input id="move" type="submit" name="move" value="{$button-text}" class="cgButton" onClick="return validate(this);"/>
};

declare function local:page-button-prev($button-text as xs:string) as element(input)
{
   <input id="movePrev" type="submit" name="move" value="{$button-text}" class="cgButton" onClick="return validatePrev(this);"/>
};

declare function local:admin-item-details($message as xs:string) as node()
{
   let $title as xs:string := "New Data Element Wizard:- common administrative item details"
   let $version := '0.1'
   
   let $content as node()* := 
   (
            <div xmlns="http://www.w3.org/1999/xhtml">
            <table class="layout">
            <tr><td class="left_header_cell">Registration Authority<font color="red">*</font></td><td colspan="2"> {lib-forms:make-select-registration-authority(request:get-parameter('registration-authority',''))} </td></tr>
            <tr><td class="left_header_cell">Version</td><td colspan="5"> {$version}{lib-forms:radio('label',$version,'true')} </td></tr>
            <tr><td class="left_header_cell">Registered by<font color="red">*</font></td><td colspan="2"> {lib-forms:make-select-registered_by(request:get-parameter('registered-by',''))} </td></tr>
            <tr><td class="left_header_cell">Administered by<font color="red">*</font></td><td colspan="2"> {lib-forms:make-select-administered_by-nameAndOrg(request:get-parameter('administered-by',''))} </td></tr>
            <tr><td class="left_header_cell">Submitted by<font color="red">*</font></td><td colspan="2"> {lib-forms:make-select-submitted_by-nameAndOrg(request:get-parameter('submitted-by',''))} </td></tr>
            <tr><td class="left_header_cell">Administrative Status<font color="red">*</font></td><td colspan="2">{lib-forms:select-from-simpleType-enum('Administrative_Status','administrative-status', false(),request:get-parameter('administrative-status',''))}</td></tr>
            <tr><td class="left_header_cell">Registration Status<font color="red">*</font></td><td colspan="2"> {lib-forms:select-from-simpleType-enum('Registration_Status','registration-status', false(),request:get-parameter('registration-status',''))}</td></tr>
            <tr><td class="left_header_cell">Administrative Note</td><td colspan="2">{lib-forms:text-area-element('administrative-note', 5, 70, request:get-parameter('administrative-note',''))}</td></tr>
            <tr><td class="left_header_cell"></td><td colspan="2"></td></tr>
            <tr><td></td><td width="40%"></td><td>{local:page-button("Next->Conceptual Domain")}</td></tr>
            </table>
            {
                local:hidden-controls-conceptual-domain(),
                local:hidden-controls-object-class(),
                local:hidden-controls-property-class(),
                local:hidden-controls-data-element-concept(), 
                local:hidden-controls-value-domain(), 
                local:hidden-controls-data-element(),
                local:hidden-controls-reference-doc(),
                lib-forms:hidden-element('state', 'state_ai')
            }

            </div>
     )
     return lib-forms:wrap-form-contents($title, $content)
};

declare function local:hidden-controls-admin-items()
{
    lib-forms:hidden-element('registration-authority', request:get-parameter('registration-authority','')),
    lib-forms:hidden-element('registered-by',request:get-parameter('registered-by','')),
    lib-forms:hidden-element('administered-by',request:get-parameter('administered-by','')),
    lib-forms:hidden-element('submitted-by',request:get-parameter('submitted-by','')),
    lib-forms:hidden-element('administrative-status', request:get-parameter('administrative-status','')),
    lib-forms:hidden-element('registration-status', request:get-parameter('registration-status','')),
    lib-forms:hidden-element('administrative-note', request:get-parameter('administrative-note',''))
};


(:ADDING CONCEPTUAL DOMAIN:)
declare function local:conceptual-domain-details($message as xs:string) as node()
{
     let $form_name := 'newDataElementWizard_cd'
     let $conceptual_domain_id := request:get-parameter('conceptual_domain_id','')
     let $title as xs:string := "New Data Element Wizard: - Conceptual Domain details"
     let $skip-name := substring-after(request:get-parameter('action',''),'delete value meaning')
     let $skip-name-index := if ($skip-name>'') then xs:int($skip-name) else 0
     let $uris := request:get-parameter('cd-ref-uri','')
     let $meanings := request:get-parameter('meanings','')
          
     let $content as node()* := 
            (
            
        <div class="tabbertab">
          <table class="layout">
              <table class="section">
                {
                if(request:get-parameter('choose-conceptual-domain','') = 'existing') 
                then (
                    <tr><td class="left_header_cell">Select Conceptual Domain</td>
                        <td><input id="choose-conceptual-domain" type="radio" name="choose-conceptual-domain" value="existing" checked="checked" onClick="this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-conceptual-domain" value="new" onClick="this.form.submit();">new</input></td>
                    </tr>,
                    
                    <tr>
                        <td class="left_header_cell">Select Existing Conceptual Domain<font color="red">*</font></td>
                        <td>{
                         
                            if(request:get-parameter('conceptual_domain_id','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id', session:get-attribute("conceptual_domain_id"),'newDataElementWizard_cd', 'Change Relationship'),
                                session:set-attribute("conceptual_domain_id", "") )
                            
                            else if(request:get-parameter('conceptual_domain_id','') != "")  then (
                                session:set-attribute("conceptual_domain_id", request:get-parameter('conceptual_domain_id','')),
                                lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id', request:get-parameter('conceptual_domain_id',''),'newDataElementWizard_cd', 'Change Relationship'))
                            else if(session:get-attribute("conceptual_domain_id") != "")  then (
                                lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id', session:get-attribute("conceptual_domain_id"),'newDataElementWizard_cd', 'Change Relationship'))
                            
                            else(
                                lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id',request:get-parameter("conceptual_domain_id",""),'newDataElementWizard_cd', 'Select Relationship')
                               
                            )    
                            
                        }
                        </td>
                    </tr>                  
               )else if(request:get-parameter('choose-conceptual-domain','')='new')
               then(
               
                    <tr><td class="left_header_cell">Select Conceptual Domain?</td>
                        <td><input type="radio" name="choose-conceptual-domain" value="existing" onClick="this.form.submit();">existing</input></td>
                        <td><input id="choose-conceptual-domain" type="radio" name="choose-conceptual-domain" value="new" checked="checked" onClick="this.form.submit();">new</input></td>
                    </tr>,
                 
                    <tr>
                        <td class="left_header_cell">Context <font color="red">*</font></td>
                        <td colspan="5">
                           {lib-forms:select-from-contexts-enum('preferred_name_context_cd',request:get-parameter('preferred_name_context_cd',''))} 
                        </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Name <font color="red">*</font></td>
                       <td colspan="5">
                          {lib-forms:input-element('name_cd', 70, request:get-parameter('name_cd',''))}
                       </td>
                    </tr>,
        
                    <tr>
                        <td class="left_header_cell">Definition</td>
                        <td colspan="5">{lib-forms:text-area-element('definitions_cd', 5, 70, request:get-parameter('definitions_cd',''))}
                        </td>
                    </tr>,
                
                    <tr>
                        <td class="left_header_cell">Language Identifier</td>
                        <td colspan="5">
                          {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_cd', false(), request:get-parameter('country-identifiers_cd','US'))}
                          {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_cd', false(), request:get-parameter('language-identifiers_cd','eng'))}
                        </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Source</td>
                       <td colspan="5">{lib-forms:input-element('sources_cd',70,request:get-parameter('sources_cd',''))}</td>
                    </tr>,
            
                    <tr><td class="row-header-cell" colspan="6">Conceptual Domain</td></tr>,
                
                <tr>
                    <td class="left_header_cell">Conceptual Domain</td>
                    <td colspan="5">
                     {
                       if(request:get-parameter('conceptual-domain-type','') = 'enumerated') 
                        then (
                            <tr><td class="left_header_cell">Enumerated Conceptual Domain?</td>
                            <td><input type="radio" name="conceptual-domain-type" value="enumerated" checked="checked">enumerated</input></td>
                            <td><input type="radio" name="conceptual-domain-type" value="non-enumerated">non-enumerated</input></td>
                            <td>{lib-forms:action-button('update', 'action' ,'','cd-enum-value-update')}</td>
                           </tr>,
                            <tr><td class="row-header-cell" colspan="6">Conceptual Domain Meanings</td></tr>,
             
                            <tr>
                             <td class="left_header_cell">Value Domain Meanings</td><td>Meaning</td><td>Reference URI</td>
                            </tr>,
                               for $meaning at $pos in $meanings
                               let $location := if($pos > $skip-name-index and $skip-name-index > 0) then (util:eval($pos - 1)) else ($pos)
                               where $pos != $skip-name-index and $meaning > ""
                               return (
                                  <tr>
                                     <td class="left_header_cell">Value {$location} Meaning</td>
                                     <td>{lib-forms:input-element('meanings', 30, $meanings[$pos])}{lib-forms:action-button(concat('delete value meaning ',$location), 'action' ,'','cd-enum-value-update')}</td>
                                     <td>{lib-forms:find-concept-id-CD('cd-ref-uri','get concept',$uris[$pos])}</td>
                           
                                  </tr>
                                  ),
                                  <tr>
                                     <td class="left_header_cell">New Value Meaning</td>
                                     <td>{lib-forms:input-element('meanings', 30, '')}{lib-forms:action-button('add new value meaning', 'action' ,'','cd-enum-value-update')}</td>
                                     <td>{lib-forms:find-concept-id-CD('cd-ref-uri','get concept','')}</td>
                                  </tr>
                              
                        )else( 
                            <tr><td class="left_header_cell">Enumerated Conceptual Domain?</td>
                              <td><input type="radio" name="conceptual-domain-type" value="enumerated" >enumerated</input></td>
                              <td><input type="radio" name="conceptual-domain-type" value="non-enumerated" checked="checked">non-enumerated</input></td>
                              <td>{lib-forms:action-button('update', 'action' ,'','cd-enum-value-update')}</td>
                            </tr>
                         )
                     }
                    
                    </td>
                    
                </tr> 
                )else(
                    <tr>{session:set-attribute("choose-conceptual-domain", "")}</tr>,
                    <tr><td class="left_header_cell">Select Conceptual Domain?</td>
                        <td><input  type="radio" name="choose-conceptual-domain" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input  type="radio" name="choose-conceptual-domain" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>
                )
              }   
              <tr></tr>
             <tr><td/><td width="40%">{local:page-button-prev("Previous->Admin Items")}</td><td>{local:page-button("Next->Object Class")}</td></tr>
               
             </table>
         
          </table>
          
          {
            local:hidden-controls-admin-items(),
            local:hidden-controls-object-class(),
            local:hidden-controls-property-class(),
            local:hidden-controls-data-element-concept(), 
            local:hidden-controls-value-domain(), 
            local:hidden-controls-data-element(),
            local:hidden-controls-reference-doc(),
            lib-forms:hidden-element('state', 'state_cd')
         }
       </div>
       
       )
       return lib-forms:wrap-form-name-contents($title,'newDataElementWizard_cd', $content)  
};

declare function local:hidden-controls-conceptual-domain()
{
   
     if(request:get-parameter('choose-conceptual-domain','') = 'new') then(
        lib-forms:hidden-element('choose-conceptual-domain',request:get-parameter('choose-conceptual-domain','')),
        lib-forms:hidden-element('preferred_name_context_cd', request:get-parameter('preferred_name_context_cd','')),
        lib-forms:hidden-element('name_cd', request:get-parameter('name_cd','')),
        lib-forms:hidden-element('definitions_cd',request:get-parameter('definitions_cd','')),
        lib-forms:hidden-element('country-identifiers_cd', request:get-parameter('country-identifiers_cd','')),
        lib-forms:hidden-element('language-identifiers_cd', request:get-parameter('language-identifiers_cd','')),
        lib-forms:hidden-element('sources_cd', request:get-parameter('sources_cd','')),
        lib-forms:hidden-element('conceptual-domain-type',request:get-parameter('conceptual-domain-type','')),(:,
        lib-forms:hidden-element('conceptual_domain_id',request:get-parameter('conceptual_domain_id','')):)
      
        let $meanings := request:get-parameter('meanings','')
        let $skip-name := substring-after(request:get-parameter('action',''),'delete value meaning')
        let $skip-name-index := if ($skip-name>'') then xs:int($skip-name) else 0
        let $uris := request:get-parameter('cd-ref-uri','')
        let $meanings := request:get-parameter('meanings','')
        let $uris := request:get-parameter('cd-ref-uri','')                
        for $meaning at $pos in $meanings
           let $location := if($pos > $skip-name-index and $skip-name-index > 0) then (util:eval($pos - 1)) else ($pos)
           where $pos != $skip-name-index and $meaning > ""
           return(
                lib-forms:hidden-element('meanings',$meanings[$pos]),
                lib-forms:hidden-element('cd-ref-uri',$uris[$pos])
           )
     )else(
       
         lib-forms:hidden-element('choose-conceptual-domain',request:get-parameter('choose-conceptual-domain','')),
         lib-forms:hidden-element('conceptual_domain_id',request:get-parameter('conceptual_domain_id','')),
         
         let $cd :=  lib-util:mdrElement("conceptual_domain",request:get-parameter('conceptual_domain_id',''))
         let $context_cd := data($cd//openMDR:context_identifier)
         return
         lib-forms:hidden-element('preferred_name_context_cd', $context_cd)
         
        
     )
};

(:END CONCEPTUAL DOMAIN:)

(:ADDING OBJECT CLASS:)
declare function local:object-class-details($message as xs:string) as node()
{
    let $savedCD := session:get-attribute('savedCD')
    let $element := lib-util:mdrElement("conceptual_domain",$savedCD)
       
    let $form_name := 'newDataElementWizard_oc'
    let $title as xs:string := "New Data Element Wizard: - Object Class details"
    let $object_class_uri_oc := request:get-parameter('object_class_uri_oc','')
    let $action := request:get-parameter('action_oc','')
    let $skip-uri := substring-after($action,'delete uri entry')
    let $skip-uri-index := if ($skip-uri>'') then xs:int($skip-uri) else 0
    let $content as node()* := 
        (
        <div class="tabbertab">
          <table class="layout">
         
              <table class="section">
               {
                if(request:get-parameter('choose-object-class','') = 'existing') 
                then (
                    <tr><td class="left_header_cell">Select Object Class</td>
                        <td><input id="choose-object-class" type="radio" name="choose-object-class" value="existing" checked="checked" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-object-class" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell"> Select Existing Object Class<font color="red">*</font></td>
                       
                       <td align="left" colspan="2">{
                         
                            if(request:get-parameter('object_class_id','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id', session:get-attribute("object_class_id"),'newDataElementWizard_oc', 'Change Relationship'),
                                session:set-attribute("object_class_id", "") )
                            
                            else if(request:get-parameter('object_class_id','') != "")  then (
                                session:set-attribute("object_class_id", request:get-parameter('object_class_id','')),
                                lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id', request:get-parameter('object_class_id',''),'newDataElementWizard_oc', 'Change Relationship'))
                             else if(session:get-attribute("object_class_id") != "")  then (
                                lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id', session:get-attribute("object_class_id"),'newDataElementWizard_oc', 'Change Relationship'))
                            
                            else(
                                lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id',request:get-parameter("object_class_id",""),'newDataElementWizard_oc', 'Select Relationship')
                            )    
                            
                        }
                        </td>
                    </tr>
                )else if(request:get-parameter('choose-object-class','')='new')
                then(  
                    <tr><td class="left_header_cell">Select Object Class</td>
                        <td><input type="radio" name="choose-object-class" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input id="choose-object-class" type="radio" name="choose-object-class" value="new" checked="checked" onClick="return this.form.submit();">new</input></td>
                     </tr>,                
                    <tr>
                        <td class="left_header_cell">Context <font color="red">*</font></td>
                        <td colspan="5">
                           {lib-forms:select-from-contexts-enum-default('preferred_name_context_oc',request:get-parameter('preferred_name_context_oc',''),request:get-parameter('preferred_name_context_cd',''))} 
                        </td>
                     </tr>,
                
                    <tr>
                       <td class="left_header_cell">Name <font color="red">*</font></td>
                       <td colspan="5">
                          {lib-forms:input-element('name_oc', 70, request:get-parameter('name_oc',''))}
                       </td>
                    </tr>,
        
                    <tr>
                       <td class="left_header_cell">Definition</td>
                       <td colspan="5">{lib-forms:text-area-element('definitions_oc', 5, 70, request:get-parameter('definitions_oc',''))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Language Identifier</td>
                       <td colspan="5">
                          {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_oc', false(), request:get-parameter('country-identifiers_oc','US'))}
                          {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_oc', false(), request:get-parameter('language-identifiers_oc','eng'))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Source</td>
                       <td colspan="5">{lib-forms:input-element('sources_oc',70,request:get-parameter('sources_oc',''))}</td>
                    </tr>,
            
                    <tr><td class="row-header-cell" colspan="6">Object Class specific properties</td></tr>,
                      
                         for $u at $pos in $object_class_uri_oc
                         where $pos != $skip-uri-index and $u > ""
                         return 
                         (
                            if($pos > $skip-uri-index and $skip-uri-index > 0) 
                            then (
                               <tr>
                                  <td class="left_header_cell">Concept Reference {util:eval($pos - 1)}</td>
                                  <td colspan="5">
                                     {
                                        lib-forms:find-concept-id-edit-false('object_class_uri_oc','get concept',$u),
                                        lib-forms:action-button(concat('delete uri entry ',util:eval($pos - 1)), 'action' ,'','oc-concept-reference')
                                     }
                                  </td>
                               </tr>
                            ) else (
                               <tr>
                                  <td class="left_header_cell">Concept Reference {$pos}</td>
                                  <td colspan="5">
                                     {
                                        lib-forms:find-concept-id-edit-false('object_class_uri_oc','get concept',$u),
                                        lib-forms:action-button(concat('delete uri entry ',$pos), 'action' ,'','oc-concept-reference')
                                     }
                                  </td>
                               </tr>
                            )
                          
                         ),
                     
                    <tr>
                       <td class="left_header_cell">New Concept Reference</td>
                       <td colspan="5">
                          {lib-forms:find-concept-id-edit-false('object_class_uri_oc','get concept','')}
                          <br></br>
                          {lib-forms:action-button('add another concept', 'action' ,'','oc-concept-reference')}
                       </td>
                    </tr>
                  )else(
                    <tr><td class="left_header_cell">Select Object Class</td>
                        <td><input type="radio" name="choose-object-class" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-object-class" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>
                )
                }
                <tr><td/><td width="40%">{local:page-button-prev("Previous->Conceptual Domain")}</td><td>{local:page-button("Next->Property Class")}</td></tr>
               
             </table>
         
          </table>
         
            {
                  local:hidden-controls-admin-items(),
                  local:hidden-controls-conceptual-domain(),
                  local:hidden-controls-property-class(),
                  local:hidden-controls-data-element-concept(), 
                  local:hidden-controls-value-domain(), 
                  local:hidden-controls-data-element(),
                  local:hidden-controls-reference-doc(),
                  lib-forms:hidden-element('state', 'state_oc')
           }
        
       </div>
      
       )
      
       return lib-forms:wrap-form-contents-withFooter($title, $content, $form_name,administered-item:html-anchor-small($element))  
};

declare function local:hidden-controls-object-class()
{
   if(request:get-parameter('choose-object-class','')='new') then(
        lib-forms:hidden-element('choose-object-class',request:get-parameter('choose-object-class','')),
        lib-forms:hidden-element('preferred_name_context_oc', request:get-parameter('preferred_name_context_oc','')),
        lib-forms:hidden-element('name_oc', request:get-parameter('name_oc','')),
        lib-forms:hidden-element('definitions_oc',request:get-parameter('definitions_oc','')),
        lib-forms:hidden-element('country-identifiers_oc', request:get-parameter('country-identifiers_oc','')),
        lib-forms:hidden-element('language-identifiers_oc', request:get-parameter('language-identifiers_oc','')),
        lib-forms:hidden-element('sources_oc', request:get-parameter('sources_oc','')),
        (:lib-forms:hidden-element('object_class_uri_oc',request:get-parameter('object_class_uri_oc','')):)
        lib-forms:hidden-element('object_class_id',request:get-parameter('object_class_id','')),
        let $object_class_uri_oc := request:get-parameter('object_class_uri_oc','')
        let $action := request:get-parameter('action_oc','')
        let $skip-uri := substring-after($action,'delete uri entry')
        let $skip-uri-index := if ($skip-uri>'') then xs:int($skip-uri) else 0
        
        for $u at $pos in $object_class_uri_oc
             where $pos != $skip-uri-index and $u > ""
             return(
                lib-forms:hidden-element('object_class_uri_oc',$object_class_uri_oc[$pos])
             ) 
                         
    )else(
        lib-forms:hidden-element('choose-object-class',request:get-parameter('choose-object-class','')),
        lib-forms:hidden-element('object_class_id', request:get-parameter('object_class_id',''))
    )
};
(:END OBJECT CLASS:)

(:ADDING PROPERTY CLASS:)
declare function local:property-class-details($message as xs:string) as node()
{
    let $savedCD := session:get-attribute('savedCD')
    let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
    let $savedOC := session:get-attribute('savedOC')
    let $elementOC := lib-util:mdrElement("object_class",$savedOC)
    
    let $form_name := 'newDataElementWizard_pc'
    let $title as xs:string := "New Data Element Wizard: - Property Class details"
    let $property_class_uri_pc := request:get-parameter('property_class_uri_pc','')
    let $action := request:get-parameter('action_pc','')
    let $skip-uri := substring-after($action,'delete uri entry')
    let $skip-uri-index := if ($skip-uri>'') then xs:int($skip-uri) else 0
    let $content as node()* := 
        (
        <div class="tabbertab">
          <table class="layout">
        
              <table class="section">
               {
               if(request:get-parameter('choose-property-class','') = 'existing') 
                then (
                    <tr><td class="left_header_cell">Choose Property Class</td>
                        <td><input id="choose-property-class" type="radio" name="choose-property-class" value="existing" checked="checked" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-property-class" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>,
                    <tr>
                      <td class="left_header_cell">Select Existing Property Class<font color="red">*</font> </td>
                      
                      <td align="left" colspan="2">{
                         
                            if(request:get-parameter('property_id','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('property','property_id', session:get-attribute("property_id"),'newDataElementWizard_pc', 'Change Relationship'),
                                session:set-attribute("property_id", "") )
                            
                            else if(request:get-parameter('property_id','') != "")  then (
                                session:set-attribute("property_id", request:get-parameter('property_id','')),
                                lib-forms:make-select-form-admin-item-edit-false('property','property_id', request:get-parameter('property_id',''),'newDataElementWizard_pc', 'Change Relationship'))
                            else if(session:get-attribute("property_id") != "")  then (
                                lib-forms:make-select-form-admin-item-edit-false('property','property_id', session:get-attribute("property_id"),'newDataElementWizard_pc', 'Change Relationship'))
                            
                            else(
                                lib-forms:make-select-form-admin-item-edit-false('property','property_id',request:get-parameter('property_id',''),'newDataElementWizard_pc', 'Select Relationship')
                            )    
                            
                        }
                        </td>
                   </tr>    
               )else if(request:get-parameter('choose-property-class','')='new')
               then(
                    
                    <tr><td class="left_header_cell">Select Property Class</td>
                         <td><input type="radio" name="choose-property-class" value="existing" onClick="return this.form.submit();">existing</input></td>
                         <td><input id="choose-property-class" type="radio" name="choose-property-class" value="new" checked="checked" onClick="return this.form.submit();">new</input></td>
                    </tr>,
               
                    <tr>
                       <td class="left_header_cell">Context <font color="red">*</font></td>
                       <td colspan="5">
                          {lib-forms:select-from-contexts-enum-default('preferred_name_context_pc',request:get-parameter('preferred_name_context_pc',''),request:get-parameter('preferred_name_context_cd',''))} 
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Name <font color="red">*</font></td>
                       <td colspan="5">
                          {lib-forms:input-element('name_pc', 70, request:get-parameter('name_pc',''))}
                       </td>
                    </tr>,
        
                    <tr>
                       <td class="left_header_cell">Definition</td>
                       <td colspan="5">{lib-forms:text-area-element('definitions_pc', 5, 70, request:get-parameter('definitions_pc',''))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Language Identifier</td>
                       <td colspan="5">
                          {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_pc', false(), request:get-parameter('country-identifiers_pc','US'))}
                          {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_pc', false(), request:get-parameter('language-identifiers_pc','eng'))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Source</td>
                       <td colspan="5">{lib-forms:input-element('sources_pc',70,request:get-parameter('sources_pc',''))}</td>
                    </tr>,
            
                    <tr><td class="row-header-cell" colspan="6">Property Class specific properties</td></tr>,
                        
                         for $u at $pos in $property_class_uri_pc
                         where $pos != $skip-uri-index and $u > ""
                         return 
                         (
                         if($pos > $skip-uri-index and $skip-uri-index > 0) 
                         then (
                            <tr>
                               <td class="left_header_cell">Concept Reference {util:eval($pos - 1)}</td>
                               <td colspan="5">
                                  {
                                     lib-forms:find-concept-id-edit-false('','get concept',$u),
                                     lib-forms:action-button(concat('delete uri entry ',util:eval($pos - 1)), 'action' ,'','p-uri')
                                  }
                               </td>
                            </tr>
                         ) else (
                            <tr>
                               <td class="left_header_cell">Concept Reference {$pos}</td>
                               <td colspan="5">
                                  {
                                     lib-forms:find-concept-id-edit-false('property_class_uri_pc','get concept',$u),
                                     lib-forms:action-button(concat('delete uri entry ',$pos), 'action' ,'','p-uri')
                                  }
                               </td>
                            </tr>
                         )
                          
                         )
                    ,
                    <tr>
                       <td class="left_header_cell">New Concept Reference</td>
                       <td colspan="5">
                          {lib-forms:find-concept-id-edit-false('property_class_uri_pc','get concept','')}
                          <br></br>
                          {lib-forms:action-button('add another concept', 'action' ,'','p-uri')}
                       </td>
                    </tr>
                 )else(
                    <tr><td class="left_header_cell">Select Property Class</td>
                        <td><input type="radio" name="choose-property-class" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-property-class" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>
                )   
               }   
               <tr><td/><td width="40%">{local:page-button-prev("Previous->Object Class")}</td><td>{local:page-button("Next->Data Element Concept")}</td></tr>
               
             </table>
        
          </table>
          {
                local:hidden-controls-admin-items(),
                local:hidden-controls-conceptual-domain(),
                local:hidden-controls-object-class(),
                local:hidden-controls-data-element-concept(), 
                local:hidden-controls-value-domain(), 
                local:hidden-controls-data-element(),
                local:hidden-controls-reference-doc(),
                lib-forms:hidden-element('state', 'state_pc')
                
         }
       </div>
       )
       return lib-forms:wrap-form-contents-withFooter($title, $content, $form_name,administered-item:html-anchor-small($elementCD),administered-item:html-anchor-small($elementOC))  
};

declare function local:hidden-controls-property-class()
{
    if(request:get-parameter('choose-property-class','')='new') then(
        lib-forms:hidden-element('choose-property-class',request:get-parameter('choose-property-class','')),
        lib-forms:hidden-element('preferred_name_context_pc', request:get-parameter('preferred_name_context_pc','')),
        lib-forms:hidden-element('name_pc', request:get-parameter('name_pc','')),
        lib-forms:hidden-element('definitions_pc',request:get-parameter('definitions_pc','')),
        lib-forms:hidden-element('country-identifiers_pc', request:get-parameter('country-identifiers_pc','')),
        lib-forms:hidden-element('language-identifiers_pc', request:get-parameter('language-identifiers_pc','')),
        lib-forms:hidden-element('sources_pc', request:get-parameter('sources_pc','')),
       (: lib-forms:hidden-element('property_class_uri_pc',request:get-parameter('property_class_uri_pc','')),:)
        lib-forms:hidden-element('property_id',request:get-parameter('property_id','')),
        
        let $property_class_uri_pc := request:get-parameter('property_class_uri_pc','')
        let $action := request:get-parameter('action_pc','')
        let $skip-uri := substring-after($action,'delete uri entry')
        let $skip-uri-index := if ($skip-uri>'') then xs:int($skip-uri) else 0
         for $u at $pos in $property_class_uri_pc
            where $pos != $skip-uri-index and $u > ""
             return 
             (
                lib-forms:hidden-element('property_class_uri_pc',$property_class_uri_pc[$pos])
             )
    ) else(
        lib-forms:hidden-element('choose-property-class',request:get-parameter('choose-property-class','')),
        lib-forms:hidden-element('property_id',request:get-parameter('property_id',''))
    )
};
(:END PROPERTY CLASS:)

declare function local:get-referenceID($id as xs:string?,$idExisting) as xs:string
{
    let $version := '0.1'
    let $reg-auth := request:get-parameter('registration-authority','')
    let $idFull := concat($reg-auth, '_', $id, '_', $version)
    let $doc-name := concat($idFull,'.xml')
    return 
    if($id>'')
    then($doc-name)
    else($idExisting)
};

declare function local:savedOCDEC()
{
 if(session:get-attribute("savedOCDEC")>'')
    then(session:get-attribute('savedOCDEC'))
 else(session:get-attribute('savedOC'))
};

declare function local:savedPCDEC()
{
 if(session:get-attribute("savedPCDEC")>'')
    then(session:get-attribute('savedPCDEC'))
 else(session:get-attribute('savedPC'))
};

declare function local:savedCDDEC()
{
 if(session:get-attribute("savedCDDEC")>'')
    then(session:get-attribute('savedCDDEC'))
 else(session:get-attribute('savedCD'))
};


declare function local:data-element-concept($message as xs:string) as node()
{
    let $savedCD := local:savedCDDEC()
    let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
    let $savedOC := local:savedOCDEC()
    let $elementOC := lib-util:mdrElement("object_class",$savedOC)
    let $savedPC := local:savedPCDEC()
    let $elementPC := lib-util:mdrElement("property",$savedPC)
    
    let $form_name := 'newDataElementWizard_dec'
    let $title as xs:string := "New Data Element Wizard: - Data Element Concept"
    let $content as node()* := 
            (
           
            <div xmlns="http://www.w3.org/1999/xhtml">
            <table class="layout">
               
               {
                if(request:get-parameter('choose-data-element-concept','') = 'existing') 
                then (
                     <tr><td class="left_header_cell">Select Data Element Concept</td>
                        <td><input id="choose-data-element-concept" type="radio" name="choose-data-element-concept" value="existing" checked="checked" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-data-element-concept" value="new" onClick="return this.form.submit();">new</input></td>
                   </tr>,
                     
                     <tr>
                       <td class="left_header_cell">Select Existing Data Element Concept<font color="red">*</font></td>
                       
                       <td align="left" colspan="2">{
                         
                            if(request:get-parameter('data_element_concept_id','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id', session:get-attribute("data_element_concept_id"),'newDataElementWizard_dec', 'Change Relationship'),
                                session:set-attribute("data_element_concept_id", "") )
                            
                            else if(request:get-parameter('data_element_concept_id','') != "")  then (
                                session:set-attribute("data_element_concept_id", request:get-parameter('data_element_concept_id','')),
                                lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id', request:get-parameter('data_element_concept_id',''),'newDataElementWizard_dec', 'Change Relationship'))
                             else if(session:get-attribute("data_element_concept_id") != "")  then (
                                lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id', session:get-attribute("data_element_concept_id"),'newDataElementWizard_dec', 'Change Relationship'))
                            
                            else(
                                lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id',request:get-parameter("data_element_concept_id",""),'newDataElementWizard_dec', 'Select Relationship')
                            )    
                            
                        }
                        </td>
                    </tr> 
               )else if(request:get-parameter('choose-data-element-concept','')='new')
               then(
                    <tr><td class="left_header_cell">Select Data Element Concept</td>
                        <td><input type="radio" name="choose-data-element-concept" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input id="choose-data-element-concept" type="radio" name="choose-data-element-concept" value="new" checked="checked" onClick="return this.form.submit();">new</input></td>
                    </tr>,

                    <tr>
                         <td class="left_header_cell">Context <font color="red">*</font></td>
                         <td colspan="5">
                            {lib-forms:select-from-contexts-enum-default('preferred_name_context_dec',request:get-parameter('preferred_name_context_dec',''),request:get-parameter('preferred_name_context_cd',''))} 
                         </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Name <font color="red">*</font></td>
                       <td colspan="5">
                          {lib-forms:input-element('name_dec', 70, request:get-parameter('name_dec',''))}
                       </td>
                    </tr>,
        
                    <tr>
                       <td class="left_header_cell">Definition</td>
                       <td colspan="5">{lib-forms:text-area-element('definitions_dec', 5, 70, request:get-parameter('definitions_dec',''))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Language Identifier</td>
                       <td colspan="5">
                          {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_dec', false(), request:get-parameter('country-identifiers_dec','US'))}
                          {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_dec', false(), request:get-parameter('language-identifiers_dec','eng'))}
                       </td>
                    </tr>,
                    <tr></tr>,
                    <tr>
                       <td class="left_header_cell">Source</td>
                       <td colspan="5">{lib-forms:input-element('sources_dec',70,request:get-parameter('sources_dec',''))}</td>
                    </tr>,
                
                    <!--<tr>
                       <td class="left_header_cell">Object Class URI</td>
                       <td align="left" colspan="2">
                          {lib-forms:find-concept-id-edit-false('object_class_uri','get object class concept',request:get-parameter('object_class_uri',''))}
                       </td>
                   </tr>-->,
                    <tr>
                        <td class="left_header_cell"> Object Class URI</td>
                        <td align="left" colspan="2">
                        {
                        
                            if(request:get-parameter('object_class_id_dec','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id_dec', session:get-attribute("object_class_id_dec"),'newDataElementWizard_dec', 'Change Relationship'),
                                session:set-attribute("object_class_id_dec", "") 
                             )
                            else if(request:get-parameter('object_class_id_dec','') != "")  then (
                                 
                                 if(request:get-parameter('object_class_id_dec','') != $savedOC and session:get-attribute("updating") eq "true") then(
                                     session:set-attribute("object_class_id_dec",request:get-parameter('object_class_id_dec','') ),
                                     lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id_dec', request:get-parameter('object_class_id_dec',''),'newDataElementWizard_dec', 'Change Relationship')
                                     , session:set-attribute("updating","")
                                     , session:set-attribute("savedOC",request:get-parameter('object_class_id_dec',''))
                                     , session:set-attribute("savedOCDEC",request:get-parameter('object_class_id_dec',''))
                                 )else(
                                    session:set-attribute("object_class_id_dec", $savedOC),
                                    lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id_dec', $savedOC,'newDataElementWizard_dec', 'Change Relationship')
                                    ,if(request:get-parameter('update','') eq "Change Relationship") 
                                    then (session:set-attribute("updating","true"))
                                    else()
                                )                                 
                            )
                            else(
                                 lib-forms:make-select-form-admin-item-edit-false('object_class','object_class_id_dec', $savedOC,'newDataElementWizard_dec', 'Select Relationship')
                                 
                            )
                        }
                        </td>
                     </tr>,
                    <!--<tr>
                       <td class="left_header_cell">Property URI</td>
                       <td align="left" colspan="2">
                          {lib-forms:find-concept-id-edit-false('property_uri','get property concept',request:get-parameter('property_uri',''))}
                       </td>
                   </tr>-->,
                    <tr>
                        <td class="left_header_cell">Property URI </td>
                        <td align="left" colspan="2">
                            {
                                if(request:get-parameter('property_id_dec','') eq "Cancel")  then (
                                    lib-forms:make-select-form-admin-item-edit-false('property','property_id_dec', session:get-attribute("property_id_dec"),'newDataElementWizard_dec', 'Change Relationship'),
                                    session:set-attribute("property_id_dec", "") )
                                
                                else if(request:get-parameter('property_id_dec','') != "")  then (
                                     if(request:get-parameter('property_id_dec','') != $savedPC and session:get-attribute("updating") eq "true") then(
                                         session:set-attribute("property_id_dec",request:get-parameter('property_id_dec','') ),
                                         lib-forms:make-select-form-admin-item-edit-false('property','property_id_dec', request:get-parameter('property_id_dec',''),'newDataElementWizard_dec', 'Change Relationship')
                                         , session:set-attribute("updating","")
                                         , session:set-attribute("savedPC",request:get-parameter('property_id_dec',''))
                                         , session:set-attribute("savedPCDEC",request:get-parameter('property_id_dec',''))
         
                                     )else(
                                        session:set-attribute("property_id_dec", $savedPC),
                                        lib-forms:make-select-form-admin-item-edit-false('property','property_id_dec', $savedPC,'newDataElementWizard_dec', 'Change Relationship'))
                                        ,if(request:get-parameter('update','') eq "Change Relationship") 
                                           then (session:set-attribute("updating","true"))
                                        else()
                                     )
                                else(
                                   lib-forms:make-select-form-admin-item-edit-false('property','property_id_dec', $savedPC,'newDataElementWizard_dec', 'Select Relationship') 
                              )                 
                            }
                        </td>
                     </tr>,
                    <tr>
                       <td class="left_header_cell">Conceptual Domain</td>
                    </tr>,
                    <tr>
                        <td class="left_header_cell"> </td>
                        <td> 
                           {
                                if(request:get-parameter('conceptual_domain_id_dec','') eq "Cancel")  then (
                                    lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id_dec', session:get-attribute("conceptual_domain_id_dec"),'newDataElementWizard_dec', 'Change Relationship'),
                                    session:set-attribute("conceptual_domain_id", "") )
                                
                                else if(request:get-parameter('conceptual_domain_id_dec','') != "")  then (
                                    if(request:get-parameter('conceptual_domain_id_dec','') != $savedCD and session:get-attribute("updating") eq "true") then(
                                         session:set-attribute("conceptual_domain_id_dec",request:get-parameter('conceptual_domain_id_dec','') ),
                                         lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id_dec', request:get-parameter('conceptual_domain_id_dec',''),'newDataElementWizard_dec', 'Change Relationship')
                                         , session:set-attribute("updating","")
                                         , session:set-attribute("savedCD",request:get-parameter('conceptual_domain_id_dec',''))
                                         , session:set-attribute("savedCDDEC",request:get-parameter('conceptual_domain_id_dec',''))
                                     )else(
                                        session:set-attribute("conceptual_domain_id_dec", $savedCD),
                                        lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id_dec', $savedCD,'newDataElementWizard_dec', 'Change Relationship'))
                                         ,if(request:get-parameter('update','') eq "Change Relationship") 
                                           then (session:set-attribute("updating","true"))
                                         else()
                                    )
                                else(
                                   lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id_dec',$savedCD,'newDataElementWizard_dec', 'Select Relationship') 
                                )                 
                          }
                        </td>
                     </tr>
                 )else(
                    <tr><td class="left_header_cell">Select Conceptual Domain?</td>
                         <td><input type="radio" name="choose-data-element-concept" value="existing" onClick="return this.form.submit();">existing</input></td>
                         <td><input type="radio" name="choose-data-element-concept" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>
                )
                }  
                <tr>
                   <td/><td width="40%">{local:page-button-prev("Previous->Property Class")}</td>
                   <td>{local:page-button("Next->Value Domain")}</td>
               </tr>                
                </table>
                    {
                        local:hidden-controls-admin-items(),
                        local:hidden-controls-conceptual-domain(),
                        local:hidden-controls-object-class(),
                        local:hidden-controls-property-class(),
                        local:hidden-controls-value-domain(), 
                        local:hidden-controls-data-element(),
                        local:hidden-controls-reference-doc(),
                        lib-forms:hidden-element('state', 'state_dec')                        
                    }
            </div>
             )
           
   return lib-forms:wrap-form-contents-withFooter($title, $content,$form_name,administered-item:html-anchor-small($elementCD), administered-item:html-anchor-small($elementOC), administered-item:html-anchor-small($elementPC))
};

declare function local:hidden-controls-data-element-concept()
{
    if(request:get-parameter('choose-data-element-concept','')='new') then(
        lib-forms:hidden-element('choose-data-element-concept',request:get-parameter('choose-data-element-concept','')),
        lib-forms:hidden-element('preferred_name_context_dec', request:get-parameter('preferred_name_context_dec','')),
        lib-forms:hidden-element('name_dec', request:get-parameter('name_dec','')),
        lib-forms:hidden-element('definitions_dec',request:get-parameter('definitions_dec','')),
        lib-forms:hidden-element('country-identifiers_dec', request:get-parameter('country-identifiers_dec','')),
        lib-forms:hidden-element('language-identifiers_dec', request:get-parameter('language-identifiers_dec','')),
        lib-forms:hidden-element('sources_dec', request:get-parameter('sources_dec','')),
        lib-forms:hidden-element('object_class_uri', request:get-parameter('object_class_uri','')), 
        lib-forms:hidden-element('property_uri', request:get-parameter('property_uri','')),
        lib-forms:hidden-element('property_id_dec', request:get-parameter('property_id_dec','')),
        lib-forms:hidden-element('object_class_id_dec', request:get-parameter('object_class_id_dec','')),
        lib-forms:hidden-element('conceptual_domain_uri', request:get-parameter('conceptual_domain_uri','')),
        lib-forms:hidden-element('conceptual_domain_id_dec', request:get-parameter('conceptual_domain_id_dec','')),
        lib-forms:hidden-element('data_element_concept_id',request:get-parameter('data_element_concept_id',''))
    ) else (
        lib-forms:hidden-element('choose-data-element-concept',request:get-parameter('choose-data-element-concept','')),
        lib-forms:hidden-element('data_element_concept_id',request:get-parameter('data_element_concept_id',''))
    )
};

declare function local:get-CD-from-DEC($message as xs:string) 
{
    if(request:get-parameter('choose-data-element-concept','')='new')
     then(
        request:get-parameter('conceptual_domain_id_dec','')
     )
     else(
         let $data_element_concept_id := request:get-parameter('data_element_concept_id','')
         let $data_element_concept := lib-util:mdrElement("data_element_concept",$data_element_concept_id)
         let $conceptual_domain_id := data($data_element_concept//openMDR:data_element_concept_conceptual_domain)
         return
               $conceptual_domain_id        
     )
};

declare function local:value-domain-type($message as xs:string) as node()
{
    let $savedCD := session:get-attribute('savedCD')
    let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
    let $savedOC := session:get-attribute('savedOC')
    let $elementOC := lib-util:mdrElement("object_class",$savedOC)
    let $savedPC := session:get-attribute('savedPC')
    let $elementPC := lib-util:mdrElement("property",$savedPC)
    let $savedDEC := session:get-attribute('savedDEC')
    let $elementDEC := lib-util:mdrElement("data_element_concept",$savedDEC)
    
   let $form_name := 'newDataElementWizard_vd'
   let $title as xs:string := "New Data Element Wizard:- value domain type"
   
   let $conceptual_domain_id := local:get-CD-from-DEC('')
   (:let $conceptual_domain_id := request:get-parameter('conceptual_domain_id','')
   :)
   
   
   let $content as node()* := 
      (
         <div xmlns="http://www.w3.org/1999/xhtml">
            <table class="layout">
                 {
                 if(request:get-parameter('choose-value-domain','') = 'existing') 
                 then (
                    <tr><td class="left_header_cell">Select Value Domain</td>
                        <td><input id="choose-value-domain" type="radio" name="choose-value-domain" value="existing" checked="checked" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-value-domain" value="new" onClick="return this.form.submit();">new</input></td>

                    </tr>,
                    <tr>
                        <td class="left_header_cell">Select Existing Value Domain<font color="red">*</font></td>
                       
                        <td align="left" colspan="2">{
                         
                            if(request:get-parameter('value_domain_id','') eq "Cancel")  then (
                                lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id', session:get-attribute("value_domain_id"),'newDataElementWizard_vd', 'Change Relationship'),
                                session:set-attribute("value_domain_id", "") )
                            
                            else if(request:get-parameter('value_domain_id','') != "")  then (
                                session:set-attribute("value_domain_id", request:get-parameter('value_domain_id','')),
                                lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id', request:get-parameter('value_domain_id',''),'newDataElementWizard_vd', 'Change Relationship'))
                             else if(session:get-attribute("value_domain_id") != "")  then (
                                lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id', session:get-attribute("value_domain_id"),'newDataElementWizard_vd', 'Change Relationship'))
                            
                            else(
                                lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id',request:get-parameter("value_domain_id",""),'newDataElementWizard_vd', 'Select Relationship')
                            )    
                            
                        }
                        </td>
                    </tr> 
               )else if(request:get-parameter('choose-value-domain','')='new')
               then(
                     <tr><td class="left_header_cell">Select Value Domain?</td>
                        <td><input type="radio" name="choose-value-domain" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input id="choose-value-domain" type="radio" name="choose-value-domain" value="new" checked="checked" onClick="return this.form.submit();">new</input></td>
                    </tr>,
                    
                    <tr>
                        <td class="left_header_cell">Context <font color="red">*</font></td>
                        <td colspan="5">
                           {lib-forms:select-from-contexts-enum-default('preferred_name_context_vd',request:get-parameter('preferred_name_context_vd',''),request:get-parameter('preferred_name_context_cd',''))} 
                        </td>
                     </tr>,
                
                     <tr>
                        <td class="left_header_cell">Name <font color="red">*</font></td>
                        <td colspan="5">
                           {lib-forms:input-element('name_vd', 70, request:get-parameter('name_vd',''))}
                        </td>
                     </tr>,
        
                     <tr>
                        <td class="left_header_cell">Definition</td>
                        <td colspan="5">{lib-forms:text-area-element('definitions_vd', 5, 70, request:get-parameter('definitions_vd',''))}
                        </td>
                     </tr>,
                
                    <tr>
                       <td class="left_header_cell">Language Identifier</td>
                       <td colspan="5">
                          {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_vd', false(), request:get-parameter('country-identifiers_vd','US'))}
                          {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_vd', false(), request:get-parameter('language-identifiers_vd','eng'))}
                       </td>
                    </tr>,
                
                    <tr>
                       <td class="left_header_cell">Source</td>
                       <td colspan="5">{lib-forms:input-element('sources_vd',70,request:get-parameter('sources_vd',''))}</td>
                    </tr>,
                
                    <tr><td class="row-header-cell" colspan="6">Conceptual Domain</td></tr>,                                                
                         
                            let $concept_domain := lib-util:mdrElement("conceptual_domain",$conceptual_domain_id)
                            return
                        
                            if ($conceptual_domain_id > '' or $conceptual_domain_id eq "Cancel") then (                   
                               <tr>
                                    
                                    <td class="left_header_cell">Conceptual Domain ID</td>
                                    <td align="left">{$conceptual_domain_id}</td>
                                    <td>{session:set-attribute("conceptual_domain_id_vd", $conceptual_domain_id)}</td>
                                    <td>{lib-forms:popup-form-search('conceptual_domain','conceptual_domain_id','newDataElementWizard_vd', 'Change Relationship')}</td>                             
                                    <td>{lib-forms:hidden-element('conceptual_domain_id_vd',$conceptual_domain_id)}</td>
                               </tr>,
                               <tr>
                                    <td class="left_header_cell">Conceptual Domain Name</td>
                                    <td align="left">{administered-item:preferred-name('conceptual_domain',$conceptual_domain_id)}</td>
                               </tr>,
                               <tr><td class="row-header-cell" colspan="6">Value Domain</td></tr>,
                               <tr>
                                   <td class="left_header_cell">Value Domain Data Type</td>
                                   <td collspan="3">{lib-forms:make-select-datatype('enum_datatype', request:get-parameter('enum_datatype',''))}</td>
                               </tr>,                          
                               <tr>
                                   <td class="left_header_cell">Value Domain Unit of Measure</td>
                                   <td collspan="3">{lib-forms:make-select-uom('enum_uom',request:get-parameter('uom',''))}</td>
                               </tr>,                         
                                  <tr>
                                   <td class="left_header_cell">Value Domain Format (E.g. MM-DD-YYYY)</td>
                                   <td collspan="3">{lib-forms:input-element('value_domain_format', 20, request:get-parameter('value_domain_format',''))}</td>
                               </tr>,                               
                                  <tr>
                                   <td class="left_header_cell">Value Domain Maximum Character Count</td>
                                   <td collspan="3">{lib-forms:input-element('char_quantity', 20, request:get-parameter('char_quantity',''))}</td>
                               </tr>,
                               
                               if($concept_domain//openMDR:value_meaning_description > '') 
                               then 
                               (
                                    <tr>
                                        <td class="left_header_cell">Possible Values</td>
                                            <td>meaning</td>
                                            <td>value</td>
                                        <td/>
                                    </tr>,
                                        for $meaning at $pos in $concept_domain//openMDR:value_meaning_description
                                        let $values := request:get-parameter('values[$pos]','')
                                        let $log := util:log-system-out('*******************')
                                        let $log := util:log-system-out($values)
                                        return (
                                           
                                           <tr class="thickBorder td">
                                              <td class="left_header_cell">Permissable Value {$pos}</td>
                                              <td>{$meaning}</td>
                                              <td>{lib-forms:input-element('values', 20, $values[$pos])}</td>
                                              
                                           </tr>
                                        )
                               ) else ()
                            ) 
                            else ( 
                                 <tr>
                                    <td class="left_header_cell">Choose Conceptual Domain</td>
                                    <td align="left">{lib-forms:make-select-form-admin-item-edit-false('conceptual_domain','conceptual_domain_id_vd',$conceptual_domain_id,'newDataElementWizard_vd','Select Relationship')}</td>
                               </tr>
                            )
                       
                )else(
                    <tr><td class="left_header_cell">Select Value Domain?</td>
                         <td><input type="radio" name="choose-value-domain" value="existing" onClick="return this.form.submit();">existing</input></td>
                        <td><input type="radio" name="choose-value-domain" value="new" onClick="return this.form.submit();">new</input></td>
                    </tr>
                )
              }  
            <tr><td/><td width="40%">{local:page-button-prev("Previous->Data Element Concept")}</td><td>{local:page-button("Next->Data Element")}</td></tr>
                             
            </table>
            {
                local:hidden-controls-admin-items(),
                local:hidden-controls-conceptual-domain(),
                local:hidden-controls-object-class(),
                local:hidden-controls-property-class(),
                local:hidden-controls-data-element-concept(), 
                local:hidden-controls-data-element(),
                local:hidden-controls-reference-doc(),
                lib-forms:hidden-element('state', 'state_vd')
            }
         </div>
        
   )
   return lib-forms:wrap-form-contents-withFooter($title, $content, $form_name,administered-item:html-anchor-small($elementCD), administered-item:html-anchor-small($elementOC), administered-item:html-anchor-small($elementPC), administered-item:html-anchor-small($elementDEC))
};


declare function local:hidden-controls-value-domain()
{
    if(request:get-parameter('choose-value-domain','')='new') then(
        lib-forms:hidden-element('choose-value-domain',request:get-parameter('choose-value-domain','')),
        lib-forms:hidden-element('preferred_name_context_vd',request:get-parameter('preferred_name_context_vd','')),
        lib-forms:hidden-element('name_vd',request:get-parameter('name_vd','')),
        lib-forms:hidden-element('definitions_vd',request:get-parameter('definitions_vd','')),
        lib-forms:hidden-element('country-identifiers_vd',request:get-parameter('country-identifiers_vd','')),
        lib-forms:hidden-element('language-identifiers_vd',request:get-parameter('language-identifiers_vd','')),
        lib-forms:hidden-element('sources_vd',request:get-parameter('sources_vd','')),
        lib-forms:hidden-element('conceptual_domain_id_vd',request:get-parameter('conceptual_domain_id_vd','')),
        lib-forms:hidden-element('value_domain_id',request:get-parameter('value_domain_id','')),
        
        lib-forms:hidden-element('enum_datatype',request:get-parameter('enum_datatype','')),
        lib-forms:hidden-element('enum_uom',request:get-parameter('enum_uom','')),
        lib-forms:hidden-element('value_domain_format',request:get-parameter('value_domain_format','')),
        lib-forms:hidden-element('char_quantity',request:get-parameter('char_quantity','')),
        for $val at $pos in request:get-parameter('values','')
        return
        lib-forms:hidden-element('values[$pos]',$val)
    )else(
        lib-forms:hidden-element('choose-value-domain',request:get-parameter('choose-value-domain','')),
        lib-forms:hidden-element('value_domain_id',request:get-parameter('value_domain_id',''))
    )
};

declare function local:savedDEDEC()
{
 if(session:get-attribute("savedDEDEC")>'')
    then(session:get-attribute('savedDEDEC'))
 else(session:get-attribute('savedDEC'))
};

declare function local:savedDEVD()
{
 if(session:get-attribute("savedDEVD")>'')
    then(session:get-attribute('savedDEVD'))
 else(session:get-attribute('savedVD'))
};

declare function local:data-element-details($message as xs:string) as node()
{
   
   let $savedCD := session:get-attribute('savedCD')
   let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
   let $savedOC := session:get-attribute('savedOC')
   let $elementOC := lib-util:mdrElement("object_class",$savedOC)
   let $savedPC := session:get-attribute('savedPC')
   let $elementPC := lib-util:mdrElement("property",$savedPC)
   let $savedDEC := local:savedDEDEC()
   let $elementDEC := lib-util:mdrElement("data_element_concept",$savedDEC)
   let $savedVD := local:savedDEVD()
   let $elementVD := lib-util:mdrElement("value_domain",$savedVD)
   
   let $form_name := 'newDataElementWizard_de'
   let $title as xs:string := "New Data Element Wizard:- data element details"
   let $content as node()* := 
            (
          <div xmlns="http://www.w3.org/1999/xhtml">
         <table class="layout">
                <tr>
                   <td class="left_header_cell">Context <font color="red">*</font></td>
                   <td colspan="5">
                      {lib-forms:select-from-contexts-enum-default('preferred_name_context_de',request:get-parameter('preferred_name_context_de',''),request:get-parameter('preferred_name_context_cd',''))} 
                   </td>
                </tr>
                
                <tr>
                   <td class="left_header_cell">Name <font color="red">*</font></td>
                   <td colspan="5">
                      {lib-forms:input-element('name_de', 70, request:get-parameter('name_de',''))}
                   </td>
                </tr>
        
                <tr>
                   <td class="left_header_cell">Definition</td>
                   <td colspan="5">{lib-forms:text-area-element('definitions_de', 5, 70, request:get-parameter('definitions_de',''))}
                   </td>
                </tr>
                
                <tr>
                   <td class="left_header_cell">Language Identifier</td>
                   <td colspan="5">
                      {lib-forms:select-from-simpleType-enum('Country_Identifier','country-identifiers_de', false(), request:get-parameter('country-identifiers_de','US'))}
                      {lib-forms:select-from-simpleType-enum('Language_Identifier','language-identifiers_de', false(), request:get-parameter('language-identifiers_de','eng'))}
                   </td>
                </tr>
                
                <tr>
                   <td class="left_header_cell">Source</td>
                   <td colspan="5">{lib-forms:input-element('sources_de',70,request:get-parameter('sources_de',''))}</td>
                </tr>
                
                <tr>
                  <td class="left_header_cell">Data Element Concept</td>
                  <td align="left" colspan="2">
                  {
                    if(request:get-parameter('data_element_concept_id_de','') eq "Cancel")  then (
                        lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id_de', session:get-attribute("data_element_concept_id_de"),'newDataElementWizard_de', 'Change Relationship'),
                        session:set-attribute("data_element_concept_id_de", "") )
                    
                    else if(request:get-parameter('data_element_concept_id_de','') != "")  then (
                        if(request:get-parameter('data_element_concept_id_de','') != $savedDEC and session:get-attribute("updating") eq "true") then(
                             session:set-attribute("data_element_concept_id_de",request:get-parameter('data_element_concept_id_de','') ),
                             lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id_de', request:get-parameter('data_element_concept_id_de',''),'newDataElementWizard_de', 'Change Relationship')
                             , session:set-attribute("updating","")
                             , session:set-attribute("savedDEC",request:get-parameter('data_element_concept_id_de',''))
                             , session:set-attribute("savedDEDEC",request:get-parameter('data_element_concept_id_de',''))
                         )else(
                        session:set-attribute("data_element_concept_id_de", $savedDEC),
                        lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id_de', $savedDEC,'newDataElementWizard_de', 'Change Relationship'))
                        ,if(request:get-parameter('update','') eq "Change Relationship") 
                            then (session:set-attribute("updating","true"))
                            else()
                        )
                    else(
                       lib-forms:make-select-form-admin-item-edit-false('data_element_concept','data_element_concept_id_de', $savedDEC,'newDataElementWizard_de', 'Change Relationship') 
                    )
                  }
                  </td>
               </tr>
               <tr>
                  <td class="left_header_cell">Value Domain</td>
                  <td align="left" colspan="2">
                  {
                    if(request:get-parameter('value_domain_id_de','') eq "Cancel")  then (
                        lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id_de', session:get-attribute("value_domain_id_de"),'newDataElementWizard_de', 'Change Relationship'),
                        session:set-attribute("value_domain_id_de", "") )
                    
                    else if(request:get-parameter('value_domain_id_de','') != "")  then (
                         if(request:get-parameter('value_domain_id_de','') != $savedOC and session:get-attribute("updating") eq "true") then(
                             session:set-attribute("value_domain_id_de",request:get-parameter('value_domain_id_de','') ),
                             lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id_de', request:get-parameter('value_domain_id_de',''),'newDataElementWizard_de', 'Change Relationship')
                             , session:set-attribute("updating","")
                             , session:set-attribute("savedVD",request:get-parameter('value_domain_id_de',''))
                             , session:set-attribute("savedDEVD",request:get-parameter('value_domain_id_de',''))
                         )else(    
                             session:set-attribute("value_domain_id_de", $savedVD),
                             lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id_de', $savedVD,'newDataElementWizard_de', 'Change Relationship'))
                                ,if(request:get-parameter('update','') eq "Change Relationship") 
                                then (session:set-attribute("updating","true"))
                                else()
                         )
                    else(
                       lib-forms:make-select-form-admin-item-edit-false('value_domain','value_domain_id_de', $savedVD,'newDataElementWizard_de', 'Change Relationship') 
                    )
                  }
                  </td>
              </tr>
              <tr><td class="left_header_cell">Example</td><td colspan="2">{lib-forms:text-area-element('example', 5, 70, request:get-parameter('example',''))}</td></tr>
              <tr><td class="left_header_cell">Precision</td><td colspan="2">{lib-forms:input-element('precision', 70,request:get-parameter('precision',''))}</td></tr>
            <tr><td/><td width="40%">{local:page-button-prev("Previous->Value Domain")}</td><td>{local:page-button("Next->Reference Doc")}</td></tr>
                
         </table>
         {
                local:hidden-controls-admin-items(),
                local:hidden-controls-conceptual-domain(),
                local:hidden-controls-object-class(),
                local:hidden-controls-property-class(),
                local:hidden-controls-data-element-concept(),
                local:hidden-controls-value-domain(), 
                local:hidden-controls-reference-doc(),
                lib-forms:hidden-element('state', 'state_de')
         }
           </div>
            )
   return lib-forms:wrap-form-contents-withFooter($title, $content,$form_name, administered-item:html-anchor-small($elementCD),
   administered-item:html-anchor-small($elementOC), administered-item:html-anchor-small($elementPC),
   administered-item:html-anchor-small($elementDEC), administered-item:html-anchor-small($elementVD))            
};

declare function local:hidden-controls-data-element()
{
    lib-forms:hidden-element('name_de', request:get-parameter('name_de','')),
    lib-forms:hidden-element('definition_de', request:get-parameter('definition_de','')),
    lib-forms:hidden-element('preferred_name_context_de',request:get-parameter('preferred_name_context_de','')),
    lib-forms:hidden-element('country-identifiers_de', request:get-parameter('country-identifiers_de','')),
    lib-forms:hidden-element('language-identifiers_de', request:get-parameter('language-identifiers_de','')),
    lib-forms:hidden-element('sources_de', request:get-parameter('sources_de','')),
    lib-forms:hidden-element('data_element_concept_id_de', request:get-parameter('data_element_concept_id_de','')),
    lib-forms:hidden-element('value_domain_id_de', request:get-parameter('value_domain_id_de','')),
    lib-forms:hidden-element('example', request:get-parameter('example','')),
    lib-forms:hidden-element('precision', request:get-parameter('precision','')) 
    
};

declare function local:associated-refdocs($message as xs:string) as node()
{
   let $form_name := 'reference_docs'
   let $savedCD := session:get-attribute('savedCD')
   let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
   let $savedOC := session:get-attribute('savedOC')
   let $elementOC := lib-util:mdrElement("object_class",$savedOC)
   let $savedPC := session:get-attribute('savedPC')
   let $elementPC := lib-util:mdrElement("property",$savedPC)
   let $savedDEC := session:get-attribute('savedDEC')
   let $elementDEC := lib-util:mdrElement("data_element_concept",$savedDEC)
   let $savedVD := session:get-attribute('savedVD')
   let $elementVD := lib-util:mdrElement("value_domain",$savedVD)
   let $savedDE := session:get-attribute('savedDE')
   let $elementDE := lib-util:mdrElement("data_element",$savedDE)
   
   let $title as xs:string := "New Data Element Wizard:- reference documents"
   let $content as node()* := 
            (
            <div xmlns="http://www.w3.org/1999/xhtml">
            <table class="layout">
            <tr><td class="left_header_cell">Reference document 1</td><td colspan="2"> {lib-forms:make-select-refdoc('refdoc1', request:get-parameter('refdoc1',''))} </td></tr>
            <tr><td class="left_header_cell">Reference document 2</td><td colspan="2"> {lib-forms:make-select-refdoc('refdoc2', request:get-parameter('refdoc2',''))} </td></tr>
            <tr><td class="left_header_cell">Reference document 3</td><td colspan="2"> {lib-forms:make-select-refdoc('refdoc3', request:get-parameter('refdoc3',''))} </td></tr>
            <tr><td/><td width="40%">{local:page-button-prev("Previous->Data Element")}</td><td>{local:page-button("Next->Summary")}</td></tr>
            </table>
            {
                local:hidden-controls-admin-items(),
                local:hidden-controls-conceptual-domain(),
                local:hidden-controls-object-class(),
                local:hidden-controls-property-class(),
                local:hidden-controls-data-element-concept(), 
                local:hidden-controls-value-domain(), 
                local:hidden-controls-data-element(),
                lib-forms:hidden-element('state', 'state_rd')
            }
            </div>
             )
             
   return lib-forms:wrap-form-contents-withFooter($title, $content,$form_name,administered-item:html-anchor-small($elementCD),
   administered-item:html-anchor-small($elementOC),administered-item:html-anchor-small($elementPC),
   administered-item:html-anchor-small($elementDEC),administered-item:html-anchor-small($elementVD),
   administered-item:html-anchor-small($elementDE))
};

declare function local:hidden-controls-reference-doc()
{
lib-forms:hidden-element('refdoc1', request:get-parameter('refdoc1','')),
lib-forms:hidden-element('refdoc2',request:get-parameter('refdoc2','')),
lib-forms:hidden-element('refdoc3',request:get-parameter('refdoc3',''))
};


declare function local:confirm($message as xs:string) as node()
{
    let $savedCD := session:get-attribute('savedCD')
   let $elementCD := lib-util:mdrElement("conceptual_domain",$savedCD)
   let $savedOC := session:get-attribute('savedOC')
   let $elementOC := lib-util:mdrElement("object_class",$savedOC)
   let $savedPC := session:get-attribute('savedPC')
   let $elementPC := lib-util:mdrElement("property",$savedPC)
   let $savedDEC := session:get-attribute('savedDEC')
   let $elementDEC := lib-util:mdrElement("data_element_concept",$savedDEC)
   let $savedVD := session:get-attribute('savedVD')
   let $elementVD := lib-util:mdrElement("value_domain",$savedVD)
   let $savedDE := session:get-attribute('savedDE')
   let $elementDE := lib-util:mdrElement("data_element",$savedDE)
   
   let $title as xs:string := "New Data Element Wizard: - Summary"
   let $content as node()* := 
      (
         <div xmlns="http://www.w3.org/1999/xhtml">
            <table class="layout">
               <tr><td/><td colspan="2">Summary of the Elements created</td></tr>
               <tr><td class="left_header_cell">Conceptual Domain</td><td colspan="2">{administered-item:html-anchor-small($elementCD)}</td></tr>
               <tr><td class="left_header_cell">Object Class</td><td colspan="2">{administered-item:html-anchor-small($elementOC)}</td></tr>
               <tr><td class="left_header_cell">Property Class</td><td colspan="2">{administered-item:html-anchor-small($elementPC)}</td></tr>
               <tr><td class="left_header_cell">Data Element Concept</td><td colspan="2">{administered-item:html-anchor-small($elementDEC)}</td></tr>
               <tr><td class="left_header_cell">Value Domain</td><td colspan="2">{administered-item:html-anchor-small($elementVD)}</td></tr>
               <tr><td class="left_header_cell">Data Element</td><td colspan="2">{administered-item:html-anchor-small($elementDE)}</td></tr>
               <tr><td></td><td colspan="2">pressing 'again' will allow you to continue entering data elements with the same set of administrative values</td></tr>              
              <tr><td></td><td width="40%"><input type="submit" name="move" value="again"/></td></tr>              
              
            </table>
           
            {
             local:hidden-controls-admin-items(),
             session:set-attribute("conceptual_domain_id",""),
             session:set-attribute("object_class_id",""),
             session:set-attribute("property_id",""),
             session:set-attribute("data_element_concept_id",""),
             session:set-attribute("value_domain_id","")
            }
         </div>
      )
   return lib-forms:wrap-form-contents($title, $content)
};

declare function local:executeCD() 
{
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $country-identifiers := request:get-parameter('country-identifiers_cd',())
   let $language-identifiers := request:get-parameter('language-identifiers_cd',())
   let $names := request:get-parameter('name_cd',())
   let $definitions := request:get-parameter('definitions_cd',())
   let $sources := request:get-parameter('sources_cd',())
   let $uri := request:get-parameter('cd-ref-uri','')
   let $preferred := '1'
   let $action := request:get-parameter('update','')
   let $meanings := request:get-parameter('meanings','')
   let $registration_status := request:get-parameter('registration-status','')
   let $context-ids := request:get-parameter('preferred_name_context_cd','')
   
   let $version := '0.1'
   let $data-identifier := lib-forms:generate-id()
   
   let $data-identifier-Existing := session:get-attribute('savedDataIdCD')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $doc-name := concat($new-identifier,'.xml')
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
   
   let $content := (
          
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources), 
                  
                  for $meaning at $pos in $meanings
                  let $vmid := lib-forms:generate-id()
                  where $meaning > ""
                    return
                        element openMDR:Value_Meaning {
                          element openMDR:value_meaning_begin_date {$creation-date},
                          element openMDR:value_meaning_description {$meaning},
                          element openMDR:value_meaning_identifier {$vmid},
                          element openMDR:reference_uri {$uri[$pos]}
                        }
                 )

   (: compose the document :)
   let $document := (
       if($meanings > '') then (
          element openMDR:Enumerated_Conceptual_Domain {
                attribute item_registration_authority_identifier {$reg-auth},
                attribute data_identifier {$data-identifier},
                attribute version {$version},
                $content
               }
      ) else (
          element openMDR:Non_Enumerated_Conceptual_Domain {
                attribute item_registration_authority_identifier {$reg-auth},
                attribute data_identifier {$data-identifier},
                attribute version {$version},
                $content
               }
      )
   )
      
   let $collection := 'conceptual_domain'
  
   let $message := lib-forms:store-document($document) 
   return
      if ($message='stored')
      then ( session:set-attribute("savedCD",$new-identifier),session:set-attribute("savedDataIdCD",$data-identifier),true())
      else response:redirect-to(xs:anyURI(concat("../web/login.xquery?calling_page=newConceptualDomain.xquery&amp;",$message)))
};

declare function local:executeOC() 
{
   let $version := '0.1'
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $registration_status := request:get-parameter('registration-status','')
   let $data-identifier := lib-forms:generate-id()
   
   let $data-identifier-Existing := session:get-attribute('savedDataIdOC')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $context-ids := request:get-parameter('preferred_name_context_oc',())
   let $names := request:get-parameter('name_oc',())
   let $definitions := request:get-parameter('definitions_oc',())
   let $language-identifiers := request:get-parameter('language-identifiers_oc',())
   let $country-identifiers := request:get-parameter('country-identifiers_oc',())
   let $sources := request:get-parameter('sources_oc',())
   let $uris := request:get-parameter('object_class_uri_oc',())
   let $preferred := '1'
      
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $doc-name := concat($new-identifier,'.xml')
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
      
   let $content := (
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources), 
                      
               for $u in $uris
               return
                  element openMDR:reference_uri {$u})
   
   (: compose the document :)
   let $document :=
      element openMDR:Object_Class {
            attribute item_registration_authority_identifier {$reg-auth},
            attribute data_identifier {$data-identifier},
            attribute version {$version},
            $content
           }
      
   let $collection := 'object_class'
   let $message := lib-forms:store-document($document) 
   return
      if ($message='stored')
      then( session:set-attribute("savedOC",$new-identifier),session:set-attribute("savedDataIdOC",$data-identifier), true())
      else response:redirect-to(xs:anyURI(concat("../web/login.xquery?calling_page=newObjectClass.xquery&amp;",$message)))

};

declare function local:executePC() 
{
   let $version := '0.1'
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $registration_status := request:get-parameter('registration-status','')
   let $data-identifier := lib-forms:generate-id()
   
   let $data-identifier-Existing := session:get-attribute('savedDataIdPC')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $doc-name := concat($new-identifier,'.xml')
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
  
   let $context-ids := request:get-parameter('preferred_name_context_pc',())
   let $names := request:get-parameter('name_pc',())
   let $definitions := request:get-parameter('definitions_pc',())
   let $language-identifiers := request:get-parameter('language-identifiers_pc',())
   let $country-identifiers := request:get-parameter('country-identifiers_pc',())
   let $sources := request:get-parameter('sources_pc',())
   let $uris := request:get-parameter('property_class_uri_pc',())
   let $preferred := '1'
   
   let $content := (
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources), 
                    for $u in $uris
                    return
                        element openMDR:reference_uri {$u})
   
   (: compose the document :)
   let $document :=
      element openMDR:Property {
            attribute item_registration_authority_identifier {$reg-auth},
            attribute data_identifier {$data-identifier},
            attribute version {$version},
            $content
           }
      
   let $collection := 'property'
   let $message := lib-forms:store-document($document) 
   return
      if ($message='stored')
      then( session:set-attribute("savedPC",$new-identifier),session:set-attribute("savedDataIdPC",$data-identifier), true())
      else response:redirect-to(xs:anyURI(concat("../web/login.xquery?calling_page=newProperty.xquery&amp;",$message)))

};

declare function local:executeDEC() 
{
   
   let $version := '0.1'
   
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $registration_status := request:get-parameter('registration-status','')
   
   let $context-ids := request:get-parameter('preferred_name_context_dec',())
   let $country-identifiers := request:get-parameter('country-identifiers_dec',())
   let $language-identifiers := request:get-parameter('language-identifiers_dec',())
   let $names := request:get-parameter('name_dec',())
   let $definitions := request:get-parameter('definitions_dec',())
   let $sources := request:get-parameter('sources_dec',())
   let $preferred := '1'
      
   let $object_class_id := request:get-parameter('object_class_id_dec','')
   
   let $property_id := request:get-parameter('property_id_dec','')
   let $conceptual_domain_id := request:get-parameter('conceptual_domain_id_dec','')
   let $object_class_uri := request:get-parameter('object_class_uri','')
   let $property_uri := request:get-parameter('property_uri','')

   let $data-identifier-oc := lib-forms:generate-id()
   let $data-identifier-pr := lib-forms:generate-id()
 
   let $full-identifier-oc := concat($reg-auth, '_', $data-identifier-oc, '_', $version)
   let $full-identifier-pr := concat($reg-auth, '_', $data-identifier-pr, '_', $version)

   let $data-identifier := lib-forms:generate-id()
   
    let $data-identifier-Existing := session:get-attribute('savedDataIdDEC')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
   let $choose_dec := request:get-parameter('choose-data-element-concept','')
   
   let $content := (
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources),
                    element openMDR:data_element_concept_conceptual_domain {$conceptual_domain_id},
                    element openMDR:data_element_concept_object_class {
                      if ($object_class_id) then ($object_class_id) else ($full-identifier-oc)
                    },
                    element openMDR:data_element_concept_property {
                      if ($property_id) then ($property_id) else ($full-identifier-pr)
                    }
    )

     
   (: compose the document :)
   let $document :=
      element openMDR:Data_Element_Concept {
            lib-make-admin-item:identifier-attributes($reg-auth,$data-identifier,$version),
            $content
           }
      
   return
   if ((
      if ($object_class_id > '')
      then 'stored'
      else ())
      )
   then (
      if ((
         if ($property_id > '')
         then 'stored'
         else ()))
      then (
          if(lib-forms:store-document($document)='stored')
          then (session:set-attribute("savedDEC",$new-identifier),session:set-attribute("savedDataIdDEC",$data-identifier),'stored')
          else ( response:redirect-to(xs:anyURI(concat("login.xquery?calling_page=newDataElementConcept.xquery&amp;","Could not store data element concept"))) )
          )
      else ( response:redirect-to(xs:anyURI(concat("login.xquery?calling_page=newDataElementConcept.xquery&amp;","Could not store property"))) )
   )
   else ( response:redirect-to(xs:anyURI(concat("login.xquery?calling_page=newDataElementConcept.xquery&amp;","Could not store object class"))) )

};

declare function local:executeVD() 
{
   
   let $version := '0.1'
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $registration_status := request:get-parameter('registration-status','')
   let $conceptual_domain_id := request:get-parameter('conceptual_domain_id_vd','')
   
   let $context-ids := request:get-parameter('preferred_name_context_vd',())
   let $country-identifiers := request:get-parameter('country-identifiers_vd',())
   let $language-identifiers := request:get-parameter('language-identifiers_vd',())
   let $names := request:get-parameter('name_vd',())
   let $definitions := request:get-parameter('definitions_vd',())
   let $sources := request:get-parameter('sources_vd',())
   let $preferred := '1'
   let $values := request:get-parameter('values',())
   let $enum_datatype := request:get-parameter('enum_datatype','')
   let $enum_uom := request:get-parameter('enum_uom','')
   let $char_quantity := request:get-parameter('char_quantity','')
   let $value_domain_format := request:get-parameter('value_domain_format','')
   
   let $data-identifier := lib-forms:generate-id()
   
   let $data-identifier-Existing := session:get-attribute('savedDataIdVD')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $doc-name := concat($new-identifier,'.xml')
   let $concept_domain := lib-util:mdrElement("conceptual_domain",$conceptual_domain_id)   
   let $value_meaning-identifier  := data($concept_domain//openMDR:value_meaning_identifier)
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
   let $content := (
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources),
                     
             for $meaning at $pos in $concept_domain//openMDR:value_meaning_description
                    return (
                       element openMDR:containing {
                         attribute permissible_value_identifier {lib-forms:generate-id()},
                         element openMDR:permissible_value_begin_date {$creation-date},
                         element openMDR:value_item {$values[$pos]},
                         element openMDR:contained_in {$value_meaning-identifier[$pos]}
                       }
             ),
            element openMDR:representing {$conceptual_domain_id},
            element openMDR:value_domain_datatype {$enum_datatype},
            element openMDR:value_domain_unit_of_measure {$enum_uom},
            element openMDR:value_domain_maximum_character_quantity{$char_quantity},
            element openMDR:value_domain_format{$value_domain_format}
    )
 
   (: compose the document :)
   let $document := (
     if($values > '' ) then (
      element openMDR:Enumerated_Value_Domain {
            attribute item_registration_authority_identifier {$reg-auth},
            attribute data_identifier {$data-identifier},
            attribute version {$version},
            $content
           }
      ) else (
       element openMDR:Non_Enumerated_Value_Domain {
            attribute item_registration_authority_identifier {$reg-auth},
            attribute data_identifier {$data-identifier},
            attribute version {$version},
            $content
           }
      )
   )
      
   let $collection := 'value_domain'
   let $message := lib-forms:store-document($document) 
   return
      if ($message='stored')
      then ( session:set-attribute("savedVD",$new-identifier),session:set-attribute("savedDataIdVD",$data-identifier), true())
      else response:redirect-to(xs:anyURI(concat("../web/login.xquery?calling_page=newValueDomain.xquery&amp;",$message)))

};

declare function local:executeDE() 
{
   let $version := '0.1'
   let $reg-auth := request:get-parameter('registration-authority','')
   let $administrative-note := request:get-parameter('administrative-note','')
   let $administrative-status := request:get-parameter('administrative-status','')
   let $administered-by := request:get-parameter('administered-by','')
   let $submitted-by := request:get-parameter('submitted-by','')
   let $registered-by := request:get-parameter('registered-by','')
   let $registration_status := request:get-parameter('registration-status','')
   let $data_element_concept_id := request:get-parameter('data_element_concept_id_de','')
   let $value_domain_id := request:get-parameter('value_domain_id_de','')
   let $example:= request:get-parameter('example','')
   let $precision := request:get-parameter('precision','')
   
   let $context-ids := request:get-parameter('preferred_name_context_de',())
   let $country-identifiers := request:get-parameter('country-identifiers_de',())
   let $language-identifiers := request:get-parameter('language-identifiers_de',())
   let $names := request:get-parameter('name_de',())
   let $definitions := request:get-parameter('definitions_de',())
   let $sources := request:get-parameter('sources_de',())
   let $preferred := '1'
   
   let $data-identifier := lib-forms:generate-id()
   
   let $data-identifier-Existing := session:get-attribute('savedDataIdDE')
    let $data-identifier := (
        if($data-identifier-Existing>'')
        then ($data-identifier-Existing)
        else ($data-identifier)
   )
   
   let $new-identifier := concat($reg-auth, '_', $data-identifier, '_', $version)
   let $creation-date := datetime:format-dateTime(current-dateTime(), "MM-dd-yyyy '  ' HH:mm:ss")
   let $content := (
            lib-make-admin-item:administration-record($administrative-note,$administrative-status,$creation-date,$registration_status),            
            lib-make-admin-item:custodians($administered-by,$registered-by,$submitted-by),
            lib-make-admin-item:havings(
                    $context-ids,
                    $country-identifiers,
                    $language-identifiers,
                    $names,
                    $definitions,
                    $preferred,
                    $sources),
                    element openMDR:data_element_precision {$precision},
                    element openMDR:representing {$value_domain_id},
                    element openMDR:expressing {$data_element_concept_id},
                    element openMDR:exemplified_by {
                    element openMDR:data_element_example_item {$example} }
    )
   
   (: compose the document :)
   let $document :=
      element openMDR:Data_Element {
            lib-make-admin-item:identifier-attributes($reg-auth,$data-identifier,$version),
            $content
           }
      
   return
          if(lib-forms:store-document($document)='stored')
          then (session:set-attribute("savedDE",$new-identifier),session:set-attribute("savedDataIdDE",$data-identifier), 'stored')
          else ( response:redirect-to(xs:anyURI(concat("login.xquery?calling_page=newDataElement.xquery&amp;","Could not store data element"))) )

};

declare option exist:serialize "media-type=text/html method=xhtml doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN doctype-system=http://www.w3.org/TR/2002/REC-xhtml1-20020801/DTD/xhtml1-transitional.dtd";

let $next-page := request:get-parameter('move','')
let $enum-value-update := request:get-parameter('enum-value-update','')
let $cd-enum-value-update := request:get-parameter('cd-enum-value-update','')
let $oc-concept-reference := request:get-parameter('oc-concept-reference','')
let $choose_cd := request:get-parameter('choose-conceptual-domain','')
let $choose_oc := request:get-parameter('choose-object-class','')
let $choose_pc := request:get-parameter('choose-property-class','')
let $choose_dec := request:get-parameter('choose-data-element-concept','')
let $choose_vd := request:get-parameter('choose-value-domain','')
let $choose_de := 'new'
let $state := request:get-parameter('state','')

return
   if ($next-page = 'Previous->Admin Items' and $state>'') 
        then local:admin-item-details('')
   else(
        if ($next-page = 'Previous->Conceptual Domain' and $state>'') 
            then local:conceptual-domain-details('')
        else(
             if ($next-page = 'Previous->Object Class' and $state>'') 
                then local:object-class-details('')
            else(
                if ($next-page = 'Previous->Property Class' and $state>'') 
                    then local:property-class-details('')
                else(
                    if ($next-page = 'Previous->Data Element Concept' and $state>'') 
                        then local:data-element-concept('')
                    else(
                        if ($next-page = 'Previous->Value Domain' and $state>'') 
                            then local:value-domain-type('')
                        else(
                            if ($next-page = 'Previous->Data Element' and $state>'') 
                                then local:data-element-details('')
                            else(
                                if ($next-page = 'Next->Conceptual Domain' and $state > '') 
                                    then (local:conceptual-domain-details(''))
                                else(
                                    if ($next-page = 'Next->Object Class' and $state>'') 
                                        then( if($choose_cd = 'new' and local:executeCD())then local:object-class-details('') else if($choose_cd='existing') then (session:set-attribute("savedCD",request:get-parameter('conceptual_domain_id','')),local:object-class-details('')) else local:conceptual-domain-details('Cannot Save') )
                                    else(
                                        if ($next-page = 'Next->Property Class' and $state>'') 
                                            then( if($choose_oc = 'new' and local:executeOC())then local:property-class-details('') else if($choose_oc='existing') then (session:set-attribute("savedOC",request:get-parameter('object_class_id','')),local:property-class-details('')) else local:object-class-details('Cannot Save') )
                                        else(
                                            if ($next-page = 'Next->Data Element Concept' and $state>'') 
                                                then( if($choose_pc = 'new' and local:executePC())then local:data-element-concept('') else if($choose_pc='existing') then (session:set-attribute("savedPC",request:get-parameter('property_id','')),local:data-element-concept('')) else local:property-class-details('Cannot Save') )
                                            else(if ($next-page = 'Next->Value Domain' and $state>'') 
                                                then( if($choose_dec = 'new' and local:executeDEC())then local:value-domain-type('') else if($choose_dec='existing') then (session:set-attribute("savedDEC",request:get-parameter('data_element_concept_id','')),local:value-domain-type('')) else local:data-element-concept('Cannot Save') )
                                                else(
                                                    if ($next-page = 'Next->Data Element' and $state>'') 
                                                        then( if($choose_vd = 'new' and local:executeVD())then local:data-element-details('') else if($choose_vd='existing') then (session:set-attribute("savedVD",request:get-parameter('value_domain_id','')),local:data-element-details('')) else local:value-domain-type('Cannot Save') )        
                                                    else(
                                                        if ($next-page = 'Next->Reference Doc' and $state>'') 
                                                            then( if($choose_de = 'new' and local:executeDE())then local:associated-refdocs('') else if($choose_de='existing') then local:associated-refdocs('') else local:data-element-details('Cannot Save') )
                                                        else(
                                                            if ($next-page = 'Next->Summary' and $state>'') 
                                                                then local:confirm('')
                                                             else(
                                                                   if($state='state_cd') 
                                                                       then(local:conceptual-domain-details(''))
                                                                   else(
                                                                        if($state='state_oc') 
                                                                       then(local:object-class-details(''))
                                                                       else(
                                                                            if($state='state_pc') 
                                                                                then(local:property-class-details(''))
                                                                            else(
                                                                                if($state='state_dec') 
                                                                                    then(local:data-element-concept(''))
                                                                                else(
                                                                                    if($state='state_vd') 
                                                                                        then local:value-domain-type('')
                                                                                    else(
                                                                                         if($state='state_de') 
                                                                                             then local:data-element-details('')
                                                                                         else(
                                                                                                session:create(),
                                                                                                session:set-attribute("conceptual_domain_id",""),
                                                                                                session:set-attribute("object_class_id",""),
                                                                                                session:set-attribute("property_id",""),
                                                                                                session:set-attribute("data_element_concept_id",""),
                                                                                                session:set-attribute("value_domain_id",""),
                                                                                                local:admin-item-details(''),
                                                                                                session:set-attribute("savedDataIdCD",""),
                                                                                                session:set-attribute("savedDataIdOC",""),
                                                                                                session:set-attribute("savedDataIdPC",""),
                                                                                                session:set-attribute("savedDataIdDEC",""),
                                                                                                session:set-attribute("savedDataIdVD",""),
                                                                                                session:set-attribute("savedDataIdDE",""),
                                                                                                session:set-attribute("savedCD",""),
                                                                                                session:set-attribute("savedOC",""),
                                                                                                session:set-attribute("savedPC",""),
                                                                                                session:set-attribute("savedDEC",""),
                                                                                                session:set-attribute("savedVD",""),
                                                                                                session:set-attribute("savedDE",""),
                                                                                                session:set-attribute("savedOCDEC",""),
                                                                                                session:set-attribute("savedPCDEC",""),
                                                                                                session:set-attribute("savedCDDEC",""),
                                                                                                 session:set-attribute("savedDEDEC",""),
                                                                                                session:set-attribute("savedDEVD","")
                                                                                            )
                                                                                          )
                                                                                       )
                                                                                    )
                                                                                )
                                                                             )
                                                                          )
                                                                       )
                                                                    )
                                                                 )
                                                             )
                                                          )
                                                        )
                                                      )
                                                   )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
    