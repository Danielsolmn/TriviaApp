//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var selectedCategoryId: Int = 9 // Default (General Knowledge)
    private var selectedDifficulty: String = "easy" // Default
    private var questions = [TriviaQuestion]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
    
    @IBOutlet weak var startButton: UIButton!
   
    @IBOutlet weak var difficultyControl: UISegmentedControl!
    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
   
    @IBAction func didChangeDifficulty(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedDifficulty = "easy"
        } else if sender.selectedSegmentIndex == 1 {
            selectedDifficulty = "medium"
        } else if sender.selectedSegmentIndex == 2 {
            selectedDifficulty = "hard"
        } else {
            selectedDifficulty = "easy"
        }
    }
    
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    let categoryOptions: [(name: String, id: Int)] = [
        ("General Knowledge", 9),
        ("Books", 10),
        ("Film", 11),
        ("Music", 12),
        ("Science & Nature", 17),
        ("Sports", 21)
    ]

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryOptions.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryOptions[row].name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryId = categoryOptions[row].id
    }
    @IBAction func didTapStartQuiz(_ sender: Any) {
        TriviaQuestionService.fetchQuestions(
                category: selectedCategoryId,
                difficulty: selectedDifficulty
            ) { [weak self] questions in
                self?.startQuiz(with: questions)
            }
        
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        // TODO: FETCH TRIVIA QUESTIONS HERE
        categoryPicker.delegate = self
            categoryPicker.dataSource = self
                
                // Hide quiz content
                hideQuizUI()
    
    }
    private func hideQuizUI() {
           questionContainerView.isHidden = true
           currentQuestionNumberLabel.isHidden = true
           categoryLabel.isHidden = true
           questionLabel.isHidden = true
           answerButton0.isHidden = true
           answerButton1.isHidden = true
           answerButton2.isHidden = true
           answerButton3.isHidden = true
       }
    private func showQuizUI() {
        questionContainerView.isHidden = false
        currentQuestionNumberLabel.isHidden = false
        categoryLabel.isHidden = false
        questionLabel.isHidden = false
        answerButton0.isHidden = false
        answerButton1.isHidden = false
        answerButton2.isHidden = false
        answerButton3.isHidden = false
        startButton.isHidden = true
        categoryPicker.isHidden = true
        difficultyControl.isHidden = true

           
       }
      private func startQuiz(with questions: [TriviaQuestion]) {
          self.questions = questions
          self.currQuestionIndex = 0
          self.numCorrectQuestions = 0
          updateQuestion(withQuestionIndex: 0)
          showQuizUI()
      }
    func decodeHTMLEntities(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return text }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed.string
        }
        return text
    }
  
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        questionLabel.text = decodeHTMLEntities(question.question)
        categoryLabel.text = decodeHTMLEntities(question.category)
        let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
       
            answerButton0.isHidden = true
            answerButton1.isHidden = true
            answerButton2.isHidden = true
            answerButton3.isHidden = true

          
            if question.type == "boolean" {
                answerButton0.setTitle(decodeHTMLEntities(answers[0]), for: .normal)
                answerButton0.isHidden = false

                answerButton1.setTitle(decodeHTMLEntities(answers[1]), for: .normal)
                answerButton1.isHidden = false
            } else {
                if answers.count > 0 {
                    answerButton0.setTitle(decodeHTMLEntities(answers[0]), for: .normal)
                    answerButton0.isHidden = false
                }
                if answers.count > 1 {
                    answerButton1.setTitle(decodeHTMLEntities(answers[1]), for: .normal)
                    answerButton1.isHidden = false
                }
                if answers.count > 2 {
                    answerButton2.setTitle(decodeHTMLEntities(answers[2]), for: .normal)
                    answerButton2.isHidden = false
                }
                if answers.count > 3 {
                    answerButton3.setTitle(decodeHTMLEntities(answers[3]), for: .normal)
                    answerButton3.isHidden = false
                }
            }
        }

  
    private func updateToNextQuestion(answer: String) {
        let isCorrect = isCorrectAnswer(answer)
        if isCorrect {
            numCorrectQuestions += 1
        }

        // Decode HTML from correctAnswer before showing it
        let title = isCorrect ? "Correct!" : "Wrong!"
        let correctAnswer = decodeHTMLEntities(questions[currQuestionIndex].correctAnswer)
        let message = "The correct answer was: \(correctAnswer)"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.currQuestionIndex += 1
            if self.currQuestionIndex < self.questions.count {
                self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
            } else {
                self.showFinalScore()
            }
        })

        present(alert, animated: true)
    }

  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
      let resetAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
              TriviaQuestionService.fetchQuestions { [weak self] newQuestions in
                  self?.startQuiz(with: newQuestions)
              }
          }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
  }
}


