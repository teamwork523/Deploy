package servers;

// import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;
import java.util.Date;
import java.text.SimpleDateFormat;

public class DownlinkWorker extends Thread {
	private Socket client = null;
	
	public void setSocket(Socket client) {
		this.client = client;
	}
	
	public void run() {
		try {
			client.setSoTimeout(Definition.RECV_TIMEOUT);
			OutputStream oStream = client.getOutputStream();
			//PrintWriter pw = new PrintWriter(client.getOutputStream(), true);
			SimpleDateFormat sDateFormat = new SimpleDateFormat("yyyyMMdd:HH:mm:ss:SSS");
			long threadId = this.getId();
			String startDate = sDateFormat.format(new Date()).toString();
			System.out.println("[" + startDate + "]" + " Downlink worker <" + threadId + "> Thread starts");

			long start = System.currentTimeMillis();
			long end = System.currentTimeMillis();
			// int batch = 0;
			byte [] buffer = Utilities.genRandomString(Definition.THROUGHPUT_DOWN_SEGMENT_SIZE).getBytes();
			while(end - start < Definition.DURATION_IPERF_MILLISECONDS) {
				oStream.write(buffer, 0, buffer.length);
				oStream.flush();
				// batch++;
				// if(batch % 50 == 0){
					end = System.currentTimeMillis();					
				// }
			}
			oStream.close();
			//pw.close();
			client.close();
            String endDate = sDateFormat.format(new Date()).toString();
			System.out.println("[" + endDate + "]" + " Downlink worker <" + threadId + "> Thread ends");
		} catch (IOException e) {
			e.printStackTrace();
	    	System.out.println("Downlink worker failed: port <" + Definition.PORT_DOWNLINK + ">");
	    }
	}
}
