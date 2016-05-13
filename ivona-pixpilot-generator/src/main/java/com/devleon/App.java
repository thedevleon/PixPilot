package com.devleon;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import com.amazonaws.auth.ClasspathPropertiesFileCredentialsProvider;
import com.ivona.services.tts.IvonaSpeechCloudClient;
import com.ivona.services.tts.model.CreateSpeechRequest;
import com.ivona.services.tts.model.CreateSpeechResult;
import com.ivona.services.tts.model.Input;
import com.ivona.services.tts.model.Voice;

/**
 * Class that generates sample synthesis and retrieves audio stream.
 */
public class App {

    private static IvonaSpeechCloudClient speechCloud;

    private static void init() {
        speechCloud = new IvonaSpeechCloudClient(
                new ClasspathPropertiesFileCredentialsProvider("IvonaCredentials.properties"));
        speechCloud.setEndpoint("https://tts.eu-west-1.ivonacloud.com");
    }

    public static void main(String[] args) throws Exception {

        if(args.length != 2)
        {
            System.out.println("Not enough parameters!");
            System.out.println("Usage: java -cp target/ivona-pixpilot-generator-1.0-SNAPSHOT.jar com.devleon.App <text> <filename>");
            return;
        }

        init();

        String outputFileName = "../SCRIPTS/WAV/PixPilot/" + args[1];
        String outputFileNameMp3 = args[1].replace("wav", "mp3");
        CreateSpeechRequest createSpeechRequest = new CreateSpeechRequest();
        Input input = new Input();
        Voice voice = new Voice();

        voice.setName("Amy");
        input.setData(args[0]);

        createSpeechRequest.setInput(input);
        createSpeechRequest.setVoice(voice);
        InputStream in = null;
        FileOutputStream outputStream = null;

        try {

            CreateSpeechResult createSpeechResult = speechCloud.createSpeech(createSpeechRequest);

            System.out.println("Success sending request.");

            System.out.println("Retrieving audio stream.");

            in = createSpeechResult.getBody();
            outputStream = new FileOutputStream(new File(outputFileNameMp3));

            byte[] buffer = new byte[2 * 1024];
            int readBytes;

            while ((readBytes = in.read(buffer)) > 0) {
                outputStream.write(buffer, 0, readBytes);
            }

            System.out.println("MP3 Downloaded: " + outputFileNameMp3);

            System.out.println("Converting...");
            Runtime rt = Runtime.getRuntime();
            Process prf = rt.exec("ffmpeg -i " + outputFileNameMp3 + " -ar 32000 -ac 1 " + outputFileName);
            int retf = prf.waitFor();
            System.out.println("ffmpeg exited with " + retf);

            System.out.println("deleting " + outputFileNameMp3);
            Process prr = rt.exec("rm " + outputFileNameMp3);
            int retr = prr.waitFor();
            System.out.println("rm exited with " + retr);

            System.out.println("Done :)");

        } finally {
            if (in != null) {
                in.close();
            }
            if (outputStream != null) {
                outputStream.close();
            }
        }
    }
}
