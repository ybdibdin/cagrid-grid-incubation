/**
*============================================================================
*  Copyright The Ohio State University Research Foundation, The University of Chicago - 
*	Argonne National Laboratory, Emory University, SemanticBits LLC, and 
*	Ekagra Software Technologies Ltd.
*
*  Distributed under the OSI-approved BSD 3-Clause License.
*  See http://ncip.github.com/cagrid-core/LICENSE.txt for details.
*============================================================================
**/
package org.cagrid.workflow.manager.common;

import javax.xml.namespace.QName;


public interface WorkflowManagerServiceConstants {
	public static final String SERVICE_NS = "http://manager.workflow.cagrid.org/WorkflowManagerService";
	public static final QName RESOURCE_KEY = new QName(SERVICE_NS, "WorkflowManagerServiceKey");
	public static final QName RESOURCE_PROPERTY_SET = new QName(SERVICE_NS, "WorkflowManagerServiceResourceProperties");

	//Service level metadata (exposed as resouce properties)
	
}