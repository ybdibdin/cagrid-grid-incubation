package org.cagrid.workflow.helper.instance.service.globus;

import org.cagrid.workflow.helper.instance.service.WorkflowInstanceHelperImpl;

import java.rmi.RemoteException;

/** 
 * DO NOT EDIT:  This class is autogenerated!
 *
 * This class implements each method in the portType of the service.  Each method call represented
 * in the port type will be then mapped into the unwrapped implementation which the user provides
 * in the WorkflowHelperImpl class.  This class handles the boxing and unboxing of each method call
 * so that it can be correclty mapped in the unboxed interface that the developer has designed and 
 * has implemented.  Authorization callbacks are automatically made for each method based
 * on each methods authorization requirements.
 * 
 * @created by Introduce Toolkit version 1.2
 * 
 */
public class WorkflowInstanceHelperProviderImpl{
	
	WorkflowInstanceHelperImpl impl;
	
	public WorkflowInstanceHelperProviderImpl() throws RemoteException {
		impl = new WorkflowInstanceHelperImpl();
	}
	

    public org.cagrid.workflow.helper.instance.stubs.CreateWorkflowInvocationHelperResponse createWorkflowInvocationHelper(org.cagrid.workflow.helper.instance.stubs.CreateWorkflowInvocationHelperRequest params) throws RemoteException {
    org.cagrid.workflow.helper.instance.stubs.CreateWorkflowInvocationHelperResponse boxedResult = new org.cagrid.workflow.helper.instance.stubs.CreateWorkflowInvocationHelperResponse();
    boxedResult.setWorkflowInvocationHelperReference(impl.createWorkflowInvocationHelper(params.getWorkflowInvocationHelperDescriptor().getWorkflowInvocationHelperDescriptor()));
    return boxedResult;
  }

    public org.cagrid.workflow.helper.instance.stubs.AddCredentialResponse addCredential(org.cagrid.workflow.helper.instance.stubs.AddCredentialRequest params) throws RemoteException {
    org.cagrid.workflow.helper.instance.stubs.AddCredentialResponse boxedResult = new org.cagrid.workflow.helper.instance.stubs.AddCredentialResponse();
    impl.addCredential(params.getServiceOperationEPR().getEndpointReference(),params.getProxyEPR().getEndpointReference());
    return boxedResult;
  }

    public org.cagrid.workflow.helper.instance.stubs.RemoveCredentialResponse removeCredential(org.cagrid.workflow.helper.instance.stubs.RemoveCredentialRequest params) throws RemoteException {
    org.cagrid.workflow.helper.instance.stubs.RemoveCredentialResponse boxedResult = new org.cagrid.workflow.helper.instance.stubs.RemoveCredentialResponse();
    impl.removeCredential(params.getProxyEPR().getEndpointReference());
    return boxedResult;
  }

    public org.cagrid.workflow.helper.instance.stubs.ReplaceCredentialResponse replaceCredential(org.cagrid.workflow.helper.instance.stubs.ReplaceCredentialRequest params) throws RemoteException {
    org.cagrid.workflow.helper.instance.stubs.ReplaceCredentialResponse boxedResult = new org.cagrid.workflow.helper.instance.stubs.ReplaceCredentialResponse();
    impl.replaceCredential(params.getServiceOperationEPR().getEndpointReference(),params.getProxyEPR().getEndpointReference());
    return boxedResult;
  }

    public org.cagrid.workflow.helper.instance.stubs.SetIsInvocationHelperSecureResponse setIsInvocationHelperSecure(org.cagrid.workflow.helper.instance.stubs.SetIsInvocationHelperSecureRequest params) throws RemoteException {
    org.cagrid.workflow.helper.instance.stubs.SetIsInvocationHelperSecureResponse boxedResult = new org.cagrid.workflow.helper.instance.stubs.SetIsInvocationHelperSecureResponse();
    impl.setIsInvocationHelperSecure(params.getServiceOperationEPR().getEndpointReference(),params.isIsSecure());
    return boxedResult;
  }

}
