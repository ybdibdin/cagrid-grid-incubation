/**
*============================================================================
*  The Ohio State University Research Foundation, Emory University,
*  the University of Minnesota Supercomputing Institute
*
*  Distributed under the OSI-approved BSD 3-Clause License.
*  See http://ncip.github.com/cagrid-grid-incubation/LICENSE.txt for details.
*============================================================================
**/
/**
*============================================================================
*============================================================================
**/
package org.cagrid.tide.service.globus;

import org.cagrid.tide.service.TideImpl;

import java.rmi.RemoteException;

/** 
 * DO NOT EDIT:  This class is autogenerated!
 *
 * This class implements each method in the portType of the service.  Each method call represented
 * in the port type will be then mapped into the unwrapped implementation which the user provides
 * in the TideImpl class.  This class handles the boxing and unboxing of each method call
 * so that it can be correclty mapped in the unboxed interface that the developer has designed and 
 * has implemented.  Authorization callbacks are automatically made for each method based
 * on each methods authorization requirements.
 * 
 * @created by Introduce Toolkit version 1.2
 * 
 */
public class TideProviderImpl{
	
	TideImpl impl;
	
	public TideProviderImpl() throws RemoteException {
		impl = new TideImpl();
	}
	

    public org.cagrid.tide.stubs.GetTideContextResponse getTideContext(org.cagrid.tide.stubs.GetTideContextRequest params) throws RemoteException {
    org.cagrid.tide.stubs.GetTideContextResponse boxedResult = new org.cagrid.tide.stubs.GetTideContextResponse();
    boxedResult.setTideContextReference(impl.getTideContext(params.getTideID()));
    return boxedResult;
  }

    public org.cagrid.tide.stubs.PutTideResponse putTide(org.cagrid.tide.stubs.PutTideRequest params) throws RemoteException {
    org.cagrid.tide.stubs.PutTideResponse boxedResult = new org.cagrid.tide.stubs.PutTideResponse();
    boxedResult.setTransferServiceContextReference(impl.putTide(params.getTideDescriptor().getTideDescriptor()));
    return boxedResult;
  }

}
