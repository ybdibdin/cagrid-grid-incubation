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
package org.cagrid.tide.service.ingestor;

import gov.nih.nci.cagrid.common.Utils;

import java.io.File;

import org.cagrid.tide.descriptor.TideDescriptor;
import org.cagrid.tide.service.TideConfiguration;
import org.cagrid.transfer.descriptor.DataStorageDescriptor;


public class FilePersistenceIngestor implements TideIngestor {

    public void ingest(TideDescriptor tide, DataStorageDescriptor desc) throws Exception {

        String storageDirS = TideConfiguration.getConfiguration().getTideStorageDir();

        File storageDir = new File(storageDirS);
        storageDir.mkdirs();
        Utils.copyFile(new File(desc.getLocation()), new File(storageDir.getAbsolutePath() + File.separator
            + tide.getTideInformation().getName() + "_" + tide.getTideInformation().getId() + ".tide"));
    }

}
