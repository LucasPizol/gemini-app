import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GenerativeModel model;
  String prompt = "";
  String answer = '';
  var lastAnswers = [];
  var loading = false;

  @override
  void initState() {
    super.initState();

    var key = "";

    model = GenerativeModel(model: "gemini-1.0-pro", apiKey: key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Center(
                child: Column(children: [
                  Text("Seja bem vindo à Gemini!"),
                  Text("Aqui você vai ver as informações sobre o Gemini!"),
                ]),
              ),
              Visibility(
                  visible: loading, child: const CircularProgressIndicator()),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: MarkdownBody(
                  data: answer,
                ),
              )),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: "Pergunta", border: OutlineInputBorder()),
                      onChanged: (value) {
                        prompt = value;
                        setState(() {});
                      },
                    ),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: Color.fromARGB(
                                              255, 122, 120, 255))))),
                      onPressed: () async {
                        if (prompt.isEmpty) {
                          return;
                        }

                        loading = true;
                        setState(() {});

                        var answers = lastAnswers
                            .map((e) =>
                                "Usuário: ${e['mine']}\nGemini: ${e['gemini']}")
                            .join("\n\n");

                        var response = await model.generateContent([
                          Content.text(
                              "Continue o chat, provido dentro das tags <chat></chat> (caso não haja chat, responda apenas a mensagem informada).\n\n <chat>$answers</chat>\n\n A nova mensagem do usuário é: $prompt")
                        ]);

                        lastAnswers.add({
                          "mine": prompt,
                          "gemini": response.text!,
                        });

                        if (response.text != null) {
                          answer = response.text!;
                        }

                        loading = false;
                        setState(() {});
                      },
                      child: Text("Enviar"))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
