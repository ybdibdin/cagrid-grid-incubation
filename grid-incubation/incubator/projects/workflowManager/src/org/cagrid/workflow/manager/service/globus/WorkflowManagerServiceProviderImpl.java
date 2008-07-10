package org.cagrid.workflow.manager.service.globus;

import java.rmi.RemoteException;

import org.cagrid.workflow.manager.service.WorkflowManagerServiceImpl;

/** 
 * DO NOT EDIT:  This class is autogenerated!
 *
 * This class implements each method in the portType of the service.  Each method call represented
 * in the port type will be then mapped into the unwrapped implementation which the user provides
 * in the WorkflowManagerServiceImpl class.  This class handles the boxing and unboxing of each method call
 * so that it can be correclty mapped in the unboxed interface that the developer has designed and 
 * has implemented.  Authorization callbacks are automatically made for each method based
 * on each methods authorization requirements.
 * 
 * @created by Introduce Toolkit version 1.1
 * 
 */
public class WorkflowManagerServiceProviderImpl{
	
	WorkflowManagerServiceImpl impl;
	
	public WorkflowManagerServiceProviderImpl() throws RemoteException {
		impl = new WorkflowManagerServiceImpl();
	}
	

    public org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromBpelResponse createWorkflowManagerInstanceFromBpel(org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromBpelRequest params) throws RemoteException {
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromBpelResponse boxedResult = new org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromBpelResponse();
    boxedResult.setWorkflowManagerInstanceReference(impl.createWorkflowManagerInstanceFromBpel(params.getBpelDescription(),params.getOperationsDescription(),params.getManagerEPR().getEndpointReference()));
    return boxedResult;
  }

    public org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorResponse createWorkflowManagerInstanceFromObjectDescriptor(org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorRequest params) throws RemoteException {
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorResponse boxedResult = new org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceFromObjectDescriptorResponse();
    boxedResult.setWorkflowManagerInstanceReference(impl.createWorkflowManagerInstanceFromObjectDescriptor(params.getWorkflowDesc().getWorkflowManagerInstanceDescriptor()));
    return boxedResult;
  }

    public org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceResponse createWorkflowManagerInstance(org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceRequest params) throws RemoteException {
    org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceResponse boxedResult = new org.cagrid.workflow.manager.stubs.CreateWorkflowManagerInstanceResponse();
    boxedResult.setWorkflowManagerInstanceReference(impl.createWorkflowManagerInstance(params.getXmlWorkflowDescription()));
    return boxedResult;
  }

    public org.cagrid.workflow.manager.stubs.GetIdentityResponse getIdentity(org.cagrid.workflow.manager.stubs.GetIdentityRequest params) throws RemoteException {
    org.cagrid.workflow.manager.stubs.GetIdentityResponse boxedResult = new org.cagrid.workflow.manager.stubs.GetIdentityResponse();
    boxedResult.setResponse(impl.getIdentity());
    return boxedResult;
  }

}
