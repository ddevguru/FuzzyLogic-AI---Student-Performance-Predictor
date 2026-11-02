import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class LearnTopic {
  final int id;
  final String title;
  final String definition;
  final String easyExplanation;
  final String? formula;
  final String practicalRelevance;

  LearnTopic({
    required this.id,
    required this.title,
    required this.definition,
    required this.easyExplanation,
    this.formula,
    required this.practicalRelevance,
  });
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final List<LearnTopic> _topics = [
    LearnTopic(
      id: 1,
      title: '1. What is Artificial Intelligence?',
      definition: 'Artificial Intelligence (AI) is a branch of computer science dedicated to creating systems capable of performing tasks that traditionally require human intelligence.',
      easyExplanation: 'Imagine teaching a computer to reason, recognize patterns, solve puzzles, and learn from experience just like a human brain does.',
      formula: null,
      practicalRelevance: 'AI serves as the umbrella discipline under which Artificial Neural Networks operate inside this lab.',
    ),
    LearnTopic(
      id: 2,
      title: '2. What is Machine Learning?',
      definition: 'Machine Learning (ML) is a subset of AI focused on building algorithms that learn patterns directly from data without being explicitly programmed.',
      easyExplanation: 'Instead of writing thousands of strict if-else rules by hand, you give the computer data and targets, and it discovers the rules automatically.',
      formula: r'y = f(x, \theta)',
      practicalRelevance: 'This app demonstrates supervised machine learning where networks map input vectors x to target outputs y.',
    ),
    LearnTopic(
      id: 3,
      title: '3. What is an Artificial Neural Network?',
      definition: 'An Artificial Neural Network (ANN) is a computational model inspired by the biological neural structure of animal brains.',
      easyExplanation: 'A web of interconnected processing nodes (neurons) organized in layers that process signal numeric inputs to produce predictions.',
      formula: r'a = \sigma\left(\sum_{i=1}^n w_i x_i + b\right)',
      practicalRelevance: 'The core simulation engine in this app implements an actual multi-layer ANN directly in pure Dart code.',
    ),
    LearnTopic(
      id: 4,
      title: '4. Biological Neuron vs Artificial Neuron',
      definition: 'Biological neurons pass electrical impulses across dendrites, soma, and axons. Artificial neurons calculate a weighted sum of inputs plus bias.',
      easyExplanation: 'Dendrites correspond to Input Signals (x), Synaptic Strengths correspond to Weights (w), Cell Body corresponds to Summation & Activation, and Axon corresponds to Neuron Output (a).',
      formula: null,
      practicalRelevance: 'Helps engineering students bridge biological neurobiology concepts with mathematical computer science.',
    ),
    LearnTopic(
      id: 5,
      title: '5. Perceptron',
      definition: 'The Perceptron is the earliest binary single-layer artificial neuron model introduced by Frank Rosenblatt in 1958.',
      easyExplanation: 'A single neuron with step-function activation that can separate linear decision boundaries.',
      formula: r'y = \begin{cases} 1 & \text{if } \sum w_i x_i + b \ge 0 \\ 0 & \text{otherwise} \end{cases}',
      practicalRelevance: 'Explains why single perceptrons failed at the XOR logic gate, motivating multi-layer networks.',
    ),
    LearnTopic(
      id: 6,
      title: '6. Weights and Biases',
      definition: 'Weights (w) control signal connection strength; Biases (b) shift activation thresholds independently of inputs.',
      easyExplanation: 'Weights act as volume knobs adjusting input influence. Bias acts as an offset determining how easily the neuron fires.',
      formula: r'z = w_1 x_1 + w_2 x_2 + \dots + w_n x_n + b',
      practicalRelevance: 'You can tap any neuron node in our simulator to inspect exact numerical weight and bias values.',
    ),
    LearnTopic(
      id: 7,
      title: '7. Input Layer',
      definition: 'The first layer in an ANN that receives raw feature values from external datasets.',
      easyExplanation: 'The entry doorway for raw data features into the network (e.g. coordinates x1, x2).',
      formula: null,
      practicalRelevance: 'Configurable in our simulator parameter panel from 1 to 10 input nodes.',
    ),
    LearnTopic(
      id: 8,
      title: '8. Hidden Layer',
      definition: 'Intermediate layers situated between input and output layers that transform inputs into non-linear representations.',
      easyExplanation: 'The internal brain layers where the network extracts feature combinations and non-linear patterns.',
      formula: r'h^{(l)} = \sigma\left(W^{(l)} h^{(l-1)} + b^{(l)}\right)',
      practicalRelevance: 'Enables our app to solve non-linearly separable problems like XOR and 2D concentric circles.',
    ),
    LearnTopic(
      id: 9,
      title: '9. Output Layer',
      definition: 'The final layer that produces model predictions, class probabilities, or continuous target values.',
      easyExplanation: 'The final decision layer giving the final prediction answer.',
      formula: null,
      practicalRelevance: 'Configured with Sigmoid for binary classification or Linear for continuous regression.',
    ),
    LearnTopic(
      id: 10,
      title: '10. Activation Functions',
      definition: 'Mathematical functions applied to neuron weighted sums to introduce non-linearity into network transformations.',
      easyExplanation: 'Without activation functions, a 100-layer neural network is mathematically identical to a simple single linear equation!',
      formula: r'\text{Sigmoid: } \frac{1}{1+e^{-z}}, \quad \text{ReLU: } \max(0,z)',
      practicalRelevance: 'Switch live between Sigmoid, ReLU, Tanh, and Linear in the simulator to see convergence differences.',
    ),
    LearnTopic(
      id: 11,
      title: '11. Forward Propagation',
      definition: 'The process where input data flows sequentially forward through network layers to calculate predicted output.',
      easyExplanation: 'Passing values from left to right through the network to get an output prediction.',
      formula: r'a^{(l)} = f\left(W^{(l)} a^{(l-1)} + b^{(l)}\right)',
      practicalRelevance: 'Animate forward propagation step-by-step using our "PROPAGATE" action button.',
    ),
    LearnTopic(
      id: 12,
      title: '12. Loss Functions',
      definition: 'Mathematical functions measuring prediction error between model outputs and target ground truth labels.',
      easyExplanation: 'A metric telling the network how bad or wrong its current prediction is.',
      formula: r'\text{MSE} = \frac{1}{N}\sum (y_i - \hat{y}_i)^2',
      practicalRelevance: 'Plotted live during training on our interactive loss vs epoch chart.',
    ),
    LearnTopic(
      id: 13,
      title: '13. Backpropagation',
      definition: 'The foundational algorithm for supervised ANN training using chain-rule calculus to calculate error gradients.',
      easyExplanation: 'Working backwards from output to input to figure out how much each weight contributed to the error.',
      formula: r'\delta^{(l)} = \left(W^{(l+1)T} \delta^{(l+1)}\right) \odot f^\prime\left(z^{(l)}\right)',
      practicalRelevance: 'Inspect exact single-step backprop calculations in our Backpropagation Inspector screen.',
    ),
    LearnTopic(
      id: 14,
      title: '14. Gradient Descent',
      definition: 'Optimization algorithm that updates weights in the opposite direction of loss gradient to minimize error.',
      easyExplanation: 'Walking downhill step-by-step in a foggy landscape until you reach the lowest valley (minimum loss).',
      formula: r'w_{\text{new}} = w_{\text{old}} - \eta \cdot \frac{\partial L}{\partial w}',
      practicalRelevance: 'Executes automatically during local training loops inside our app.',
    ),
    LearnTopic(
      id: 15,
      title: '15. Learning Rate (η)',
      definition: 'Hyperparameter controlling step size taken during parameter gradient updates.',
      easyExplanation: 'Step size setting: too large causes overshooting/instability; too small causes slow training.',
      formula: null,
      practicalRelevance: 'Adjust learning rate slider from 0.001 to 1.0 in real-time.',
    ),
    LearnTopic(
      id: 16,
      title: '16. Training Epochs',
      definition: 'One complete pass of the full training dataset through the neural network during training.',
      easyExplanation: 'How many times the network reviews the entire textbook before taking the test.',
      formula: null,
      practicalRelevance: 'Watch current epoch counter update dynamically during live training.',
    ),
    LearnTopic(
      id: 17,
      title: '17. Batch Size',
      definition: 'Number of training examples processed in one forward/backward pass before updating weights.',
      easyExplanation: 'Grouping study questions together before checking answer keys.',
      formula: null,
      practicalRelevance: 'Our app uses online SGD and full-batch processing options.',
    ),
    LearnTopic(
      id: 18,
      title: '18. Training vs Validation Data',
      definition: 'Training data tunes weights; Validation data checks generalizability on unseen samples.',
      easyExplanation: 'Study homework problems vs pop quiz problems to ensure real learning occurred.',
      formula: null,
      practicalRelevance: 'Our synthetic datasets automatically split train and validation sets.',
    ),
    LearnTopic(
      id: 19,
      title: '19. Overfitting and Underfitting',
      definition: 'Overfitting occurs when model memorizes training noise; Underfitting occurs when model is too simple.',
      easyExplanation: 'Overfitting = memorizing test answers without understanding concept. Underfitting = not studying enough.',
      formula: null,
      practicalRelevance: 'Observed on our loss chart when validation loss starts rising while training loss drops.',
    ),
    LearnTopic(
      id: 20,
      title: '20. Generalization',
      definition: 'The ability of a trained neural network to make accurate predictions on novel, unseen data.',
      easyExplanation: 'Applying learned concepts successfully to real-world exam questions you have never seen before.',
      formula: null,
      practicalRelevance: 'Evaluated in our prediction playground and analytics tab.',
    ),
    LearnTopic(
      id: 21,
      title: '21. Model Evaluation Metrics',
      definition: 'Quantitative measurements including Accuracy, Precision, Recall, F1-Score, MSE, and MAE.',
      easyExplanation: 'Scorecards evaluating model performance across classification and regression tasks.',
      formula: r'\text{F1} = \frac{2 \cdot P \cdot R}{P + R}',
      practicalRelevance: 'Calculated and displayed dynamically in our Analytics dashboard.',
    ),
    LearnTopic(
      id: 22,
      title: '22. Advantages of ANN',
      definition: 'Non-linear modeling capacity, feature learning, adaptability, fault tolerance, parallel processing.',
      easyExplanation: 'Can learn almost any complex pattern without manual feature engineering.',
      formula: null,
      practicalRelevance: 'Exploration section detailing why ANNs power modern AI.',
    ),
    LearnTopic(
      id: 23,
      title: '23. Limitations of ANN',
      definition: 'Requires large data, black-box interpretability challenges, hyperparameter sensitivity, computation cost.',
      easyExplanation: 'Hard to explain exact reasoning behind specific outputs.',
      formula: null,
      practicalRelevance: 'Detailed card explanations in our learning library.',
    ),
    LearnTopic(
      id: 24,
      title: '24. Applications of ANN',
      definition: 'Computer vision, speech recognition, NLP, robotics, medical diagnostics, financial forecasting.',
      easyExplanation: 'Powering facial recognition, voice assistants, autonomous vehicles, and disease detection.',
      formula: null,
      practicalRelevance: 'Explored in detail inside our ANN Applications Explorer tab.',
    ),
    LearnTopic(
      id: 25,
      title: '25. ANN vs Traditional Algorithms',
      definition: 'Traditional algorithms use explicit hardcoded rules; ANNs learn implicit features from data.',
      easyExplanation: 'If-else rules vs learning pattern matrices directly from data.',
      formula: null,
      practicalRelevance: 'Contrasted in our educational reference section.',
    ),
    LearnTopic(
      id: 26,
      title: '26. ANN vs Genetic Algorithms',
      definition: 'ANNs use gradient-based gradient descent optimization; GAs use bio-inspired evolutionary selection.',
      easyExplanation: 'Calculus-based gradient steps vs survival-of-the-fittest mutation and crossover.',
      formula: null,
      practicalRelevance: 'Comparative analysis for engineering project viva preparation.',
    ),
  ];

  int? _expandedTopicId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learn Artificial Neural Networks',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '26 core engineering curriculum topics with formulas, intuitive explanations & lab relevance',
            style: TextStyle(
              color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _topics.length,
            itemBuilder: (context, idx) {
              final topic = _topics[idx];
              final isExpanded = _expandedTopicId == topic.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded ? AppColors.gold : (isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
                  ),
                ),
                child: ExpansionTile(
                  key: Key('topic_${topic.id}'),
                  title: Text(
                    topic.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: isExpanded ? AppColors.gold : Colors.grey,
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _expandedTopicId = expanded ? topic.id : null;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection('Formal Definition', topic.definition, isDark),
                          _buildSection('Easy Intuitive Explanation', topic.easyExplanation, isDark),
                          if (topic.formula != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                topic.formula!,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  color: isDark ? Colors.cyanAccent : AppColors.electricBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          _buildSection('Relevance to this App', topic.practicalRelevance, isDark, isHighlight: true),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.gold : (isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }
}
