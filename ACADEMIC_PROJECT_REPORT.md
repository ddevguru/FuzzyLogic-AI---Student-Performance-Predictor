# 🎓 FORMAL ACADEMIC PROJECT REPORT

## Project Title: FuzzyLogic AI - Student Academic Performance Prediction System
**Document Type**: Engineering Major Project Report & Mathematical Specification  
**Architecture**: Flutter (Material 3 Mobile/Web) + Node.js (Express API) + PostgreSQL + Mamdani FIS  

---

# 1. INTRODUCTION & THEORETICAL FOUNDATION

## 1.1 Classical Boolean Logic vs. Fuzzy Logic
In classical Boolean logic, a set $A$ defined over a universe of discourse $X$ is characterized by a binary characteristic function $\chi_A$:

$$\chi_A: X \rightarrow \{0, 1\}$$

where:

$$\chi_A(x) = \begin{cases} 1 & \text{if } x \in A \\ 0 & \text{if } x \notin A \end{cases}$$

However, real-world human evaluation, decision-making, and academic performance assessment involve inherent uncertainty, vagueness, and partial truths.

**Fuzzy Logic**, introduced by Lotfi A. Zadeh (1965), generalizes the crisp characteristic function into a **membership function** $\mu_A$:

$$\mu_A: X \rightarrow [0, 1]$$

where $\mu_A(x)$ represents the degree of membership of element $x$ in fuzzy set $A$. A fuzzy set $A$ in $X$ is formally defined as an ordered pair set:

$$A = \left\{ (x, \mu_A(x)) \;\middle|\; x \in X \right\}$$

---

## 1.2 Motivation for Fuzzy Logic in Academic Performance Assessment
Traditional academic evaluation suffers from rigid binary boundary errors:
- If attendance required for a "High" category is $\ge 75\%$, a student with $74.9\%$ attendance is classified as "Medium" or "Unsatisfactory", treating $74.9\%$ and $30.0\%$ identically.
- Linear weighted formulas ($\text{Score} = w_1 x_1 + w_2 x_2 + w_3 x_3 + w_4 x_4$) assume linear independence and fail to represent non-linear human decision logic.

A Mamdani Fuzzy Inference System (FIS) maps non-linear, multi-dimensional student performance indicators into precise continuous performance scores and risk categories.

---

# 2. PROBLEM STATEMENT

Conventional grading systems in academic institutions face three primary mathematical and operational limitations:

1. **Discontinuous Boundary Jump Errors**:
   Strict threshold functions $f(x) = \mathbf{1}_{x \ge \theta}$ cause drastic output jumps at boundary points $x = \theta - \epsilon$ versus $x = \theta + \epsilon$.
2. **Inability to Model Interaction Effects**:
   A student with $95\%$ attendance but $20\%$ exam marks should not automatically pass just because their weighted numerical average reaches $50\%$. Real academic evaluation requires conditional rule logic ($\text{IF } \text{Test} = \text{Low} \Rightarrow \text{Performance} = \text{Poor}$).
3. **Black-Box Predictor Problem**:
   Machine learning algorithms (such as Deep Neural Networks) output raw predictions without providing interpretable rule activations ($\mu_{R_k}$) or visual proof of decision reasoning.

---

# 3. PROPOSED SYSTEM ARCHITECTURE & WORKING

## 3.1 Architectural Diagram

```text
┌───────────────────────────────────────────────────────────────────────────┐
│                       FLUTTER MOBILE & WEB CLIENT                         │
│   • Material 3 UI (Navy #002350, Blue #1769AA, Gold #D2AE39)               │
│   • Interactive Sliders (Attendance, Test, Assignment, Study Hours)       │
│   • FL Chart Interactive Fuzzy Curves & Analytics Dashboard               │
└─────────────────────────────────────┬─────────────────────────────────────┘
                                      │ HTTPS / REST API (JWT Bearer Token)
                                      ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                      NODE.JS + EXPRESS BACKEND SERVER                     │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                    MAMDANI FUZZY LOGIC ENGINE                       │  │
│  │                                                                     │  │
│  │   Crisp Inputs (x₁, x₂, x₃, x₄)                                     │  │
│  │             │                                                       │  │
│  │             ▼                                                       │  │
│  │   Fuzzification: μ_Low(x), μ_Med(x), μ_High(x)                      │  │
│  │             │                                                       │  │
│  │             ▼                                                       │  │
│  │   Mamdani Rule Evaluation: α_k = min(μ_A, μ_B, μ_C, μ_D)           │  │
│  │             │                                                       │  │
│  │             ▼                                                       │  │
│  │   Aggregation: μ_agg(y) = max_{k} [ min(α_k, μ_{Output, k}(y)) ]    │  │
│  │             │                                                       │  │
│  │             ▼                                                       │  │
│  │   Centroid Defuzzification: y* = Σ(y · μ_agg(y)) / Σ(μ_agg(y))     │  │
│  └──────────────────────────────────┬──────────────────────────────────┘  │
│  ┌──────────────────────────────────▼──────────────────────────────────┐  │
│  │                   DYNAMIC RECOMMENDATION ENGINE                     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────┬─────────────────────────────────────┘
                                      │ PostgreSQL Pool (pg)
                                      ▼
┌───────────────────────────────────────────────────────────────────────────┐
│                          POSTGRESQL DATABASE                              │
│   • users (id, name, email, password_hash, role)                          │
│   • student_profiles (id, user_id, roll_number, course, semester, dept)   │
│   • performance_records (id, student_id, scores, levels, risk)            │
│   • fuzzy_results (id, performance_id, membership_values, defuzz_score)   │
└───────────────────────────────────────────────────────────────────────────┘
```

---

# 4. MATHEMATICAL FORMULATION OF THE FUZZY LOGIC ENGINE

The Mamdani Fuzzy Inference Engine executes a 5-stage mathematical transformation pipeline:

```text
Crisp Inputs ──► Fuzzification ──► Rule Evaluation ──► Aggregation ──► Centroid Defuzzification ──► Crisp Output
```

---

## 4.1 Fuzzification & Membership Function Formulas

### 1. Triangular Membership Function Formula
A triangular membership function $\mu_{tri}(x; a, b, c)$ is parametrized by three real values $a < b < c$:

$$\mu_{tri}(x; a, b, c) = \max \left( 0, \, \min \left( \frac{x - a}{b - a}, \, \frac{c - x}{c - b} \right) \right)$$

In explicit piecewise notation:

$$\mu_{tri}(x; a, b, c) = \begin{cases} 
0, & x \le a \\
\frac{x - a}{b - a}, & a < x < b \\
1, & x = b \\
\frac{c - x}{c - b}, & b < x < c \\
0, & x \ge c 
\end{cases}$$

---

### 2. Trapezoidal Membership Function Formula
A trapezoidal membership function $\mu_{trap}(x; a, b, c, d)$ is parametrized by four real values $a < b \le c < d$:

$$\mu_{trap}(x; a, b, c, d) = \max \left( 0, \, \min \left( \frac{x - a}{b - a}, \, 1, \, \frac{d - x}{d - c} \right) \right)$$

In explicit piecewise notation:

$$\mu_{trap}(x; a, b, c, d) = \begin{cases} 
0, & x \le a \\
\frac{x - a}{b - a}, & a < x < b \\
1, & b \le x \le c \\
\frac{d - x}{d - c}, & c < x < d \\
0, & x \ge d 
\end{cases}$$

---

## 4.2 Membership Function Parameters for Input Variables

### Variable 1: Attendance $x_1 \in [0, 100]\%$
$$\mu_{\text{Att, Low}}(x_1) = \mu_{trap}(x_1; -10, 0, 25, 45)$$
$$\mu_{\text{Att, Medium}}(x_1) = \mu_{tri}(x_1; 30, 52.5, 75)$$
$$\mu_{\text{Att, High}}(x_1) = \mu_{trap}(x_1; 65, 85, 100, 110)$$

### Variable 2: Test Score $x_2 \in [0, 100]$
$$\mu_{\text{Test, Low}}(x_2) = \mu_{trap}(x_2; -10, 0, 25, 45)$$
$$\mu_{\text{Test, Medium}}(x_2) = \mu_{tri}(x_2; 30, 52.5, 75)$$
$$\mu_{\text{Test, High}}(x_2) = \mu_{trap}(x_2; 65, 85, 100, 110)$$

### Variable 3: Assignment Performance $x_3 \in [0, 100]\%$
$$\mu_{\text{Asg, Poor}}(x_3) = \mu_{trap}(x_3; -10, 0, 25, 45)$$
$$\mu_{\text{Asg, Average}}(x_3) = \mu_{tri}(x_3; 30, 52.5, 75)$$
$$\mu_{\text{Asg, Good}}(x_3) = \mu_{trap}(x_3; 65, 85, 100, 110)$$

### Variable 4: Study Hours $x_4 \in [0, 12]$ hrs/day
$$\mu_{\text{Std, Low}}(x_4) = \mu_{trap}(x_4; -2, 0, 1.5, 3.5)$$
$$\mu_{\text{Std, Medium}}(x_4) = \mu_{tri}(x_4; 2, 4.5, 7)$$
$$\mu_{\text{Std, High}}(x_4) = \mu_{trap}(x_4; 5.5, 8.5, 12, 14)$$

---

## 4.3 Output Fuzzy Sets $y \in [0, 100]$

- **POOR**: $\mu_{\text{Out, Poor}}(y) = \mu_{trap}(y; -10, 0, 20, 40)$
- **AVERAGE**: $\mu_{\text{Out, Average}}(y) = \mu_{tri}(y; 35, 50, 65)$
- **GOOD**: $\mu_{\text{Out, Good}}(y) = \mu_{tri}(y; 60, 67.5, 77.5)$
- **VERY_GOOD**: $\mu_{\text{Out, VeryGood}}(y) = \mu_{tri}(y; 75, 82.5, 90)$
- **EXCELLENT**: $\mu_{\text{Out, Excellent}}(y) = \mu_{trap}(y; 87.5, 95, 100, 110)$

---

## 4.4 Mamdani Inference & Operator Mathematical Definitions

### 1. Fuzzy T-Norm (Intersection / AND Operator)
In Mamdani inference, the $\text{AND}$ connective between antecedents is evaluated using the minimum operator:

$$\mu_{A \cap B}(x) = \min \left( \mu_A(x), \, \mu_B(x) \right)$$

### 2. Rule Firing Strength $\alpha_k$
For a fuzzy rule $R_k$:
$$\text{IF } x_1 \text{ IS } A_k \text{ AND } x_2 \text{ IS } B_k \text{ AND } x_3 \text{ IS } C_k \text{ AND } x_4 \text{ IS } D_k \text{ THEN } y \text{ IS } O_k$$

The rule firing strength $\alpha_k \in [0, 1]$ is computed as:

$$\alpha_k = \min \left( \mu_{A_k}(x_1), \, \mu_{B_k}(x_2), \, \mu_{C_k}(x_3), \, \mu_{D_k}(x_4) \right)$$

### 3. Consequent Implication (Clipping Operator)
The clipped output membership function for rule $R_k$ is defined by:

$$\mu_{O'_k}(y) = \min \left( \alpha_k, \, \mu_{O_k}(y) \right)$$

### 4. Fuzzy S-Norm Aggregation (Union / OR Operator)
All $N = 20$ rule outputs are aggregated into a unified output fuzzy set $\mu_{agg}(y)$ using the maximum operator:

$$\mu_{agg}(y) = \max_{k=1}^{N} \left[ \mu_{O'_k}(y) \right] = \max_{k=1}^{20} \left[ \min \left( \alpha_k, \, \mu_{O_k}(y) \right) \right]$$

---

## 4.5 Centroid Defuzzification Formula (Center of Gravity - COG)

The aggregated fuzzy membership function $\mu_{agg}(y)$ is defuzzified into a crisp numerical output score $y^*$ using the continuous Center of Gravity (Centroid) formula:

$$y^* = \frac{\int_{0}^{100} y \cdot \mu_{agg}(y) \, dy}{\int_{0}^{100} \mu_{agg}(y) \, dy}$$

### Discrete Numerical Approximation (Step Size $\Delta y = 0.5$)
In the Node.js implementation, the continuous integral is evaluated numerically using discrete summation with step size $\Delta y = 0.5$:

$$y^* \approx \frac{\sum_{j=0}^{M} y_j \cdot \mu_{agg}(y_j)}{\sum_{j=0}^{M} \mu_{agg}(y_j)}$$

where $y_j = 0, 0.5, 1.0, 1.5, \dots, 100.0$ and $M = 200$.

---

# 5. STEP-BY-STEP WORKED NUMERICAL EXAMPLE

Let us evaluate a sample student with the following crisp inputs:
- Attendance $x_1 = 82\%$
- Test Score $x_2 = 76$
- Assignment Score $x_3 = 88\%$
- Study Hours $x_4 = 5.0$ hrs/day

---

### Step 1: Fuzzification Calculations

1. **Attendance ($x_1 = 82$)**:
   $$\mu_{\text{Att, Low}}(82) = 0.00$$
   $$\mu_{\text{Att, Medium}}(82) = 0.00$$
   $$\mu_{\text{Att, High}}(82) = \mu_{trap}(82; 65, 85, 100, 110) = \frac{82 - 65}{85 - 65} = \frac{17}{20} = 0.85$$

2. **Test Score ($x_2 = 76$)**:
   $$\mu_{\text{Test, Low}}(76) = 0.00$$
   $$\mu_{\text{Test, Medium}}(76) = 0.00$$
   $$\mu_{\text{Test, High}}(76) = \mu_{trap}(76; 65, 85, 100, 110) = \frac{76 - 65}{85 - 65} = \frac{11}{20} = 0.55$$

3. **Assignment Score ($x_3 = 88$)**:
   $$\mu_{\text{Asg, Poor}}(88) = 0.00$$
   $$\mu_{\text{Asg, Average}}(88) = 0.00$$
   $$\mu_{\text{Asg, Good}}(88) = \mu_{trap}(88; 65, 85, 100, 110) = 1.00 \quad (\text{since } 85 \le 88 \le 100)$$

4. **Study Hours ($x_4 = 5.0$)**:
   $$\mu_{\text{Std, Low}}(5.0) = 0.00$$
   $$\mu_{\text{Std, Medium}}(5.0) = \mu_{tri}(5.0; 2, 4.5, 7) = \frac{7 - 5.0}{7 - 4.5} = \frac{2.0}{2.5} = 0.80$$
   $$\mu_{\text{Std, High}}(5.0) = \mu_{trap}(5.0; 5.5, 8.5, 12, 14) = 0.00$$

---

### Step 2: Rule Firing Strengths

- **Rule R7**: IF Test IS High AND Assignment IS Good THEN Performance IS VERY_GOOD
  $$\alpha_7 = \min(\mu_{\text{Test, High}}, \mu_{\text{Asg, Good}}) = \min(0.55, 1.00) = 0.55$$

- **Rule R10**: IF Attendance IS High AND Assignment IS Good AND Test IS High THEN Performance IS EXCELLENT
  $$\alpha_{10} = \min(\mu_{\text{Att, High}}, \mu_{\text{Asg, Good}}, \mu_{\text{Test, High}}) = \min(0.85, 1.00, 0.55) = 0.55$$

- **Rule R11**: IF Attendance IS Medium AND Test IS High AND Assignment IS Good THEN Performance IS VERY_GOOD
  $$\alpha_{11} = \min(0.00, 0.55, 1.00) = 0.00$$

---

### Step 3: Aggregation & Centroid Calculation
The aggregated fuzzy output combines $\text{VERY\_GOOD}$ ($\alpha = 0.55$) centered around $y = 82.5$ and $\text{EXCELLENT}$ ($\alpha = 0.55$) centered around $y = 95.0$.

Evaluating discrete summation $y^* = \frac{\sum y \cdot \mu_{agg}(y)}{\sum \mu_{agg}(y)}$:

$$y^* = 88.62\%$$

---

### Step 4: Final Classification & Risk Mapping

- **Performance Score**: **88.62%**
- **Performance Level**: **Very Good** ($75\% \le 88.62\% < 90\%$)
- **Academic Risk Level**: **Very Low Risk** ($75\% \le 88.62\% \le 100\%$)

---

# 6. SUMMARY OF CLASSIFICATION BOUNDARIES

| Category Name | Performance Score Range ($y^*$) | Academic Risk Mapping |
| :--- | :--- | :--- |
| **Poor** | $0.0 \le y^* < 40.0$ | **High Risk** |
| **Average** | $40.0 \le y^* < 60.0$ | **Moderate Risk** |
| **Good** | $60.0 \le y^* < 75.0$ | **Low Risk** |
| **Very Good** | $75.0 \le y^* < 90.0$ | **Very Low Risk** |
| **Excellent** | $90.0 \le y^* \le 100.0$ | **Very Low Risk** |

---

# 7. CONCLUSION

The **FuzzyLogic AI Student Performance Predictor** successfully replaces arbitrary linear averages with a continuous, human-interpretable Mamdani Fuzzy Inference Engine. By combining formal triangular/trapezoidal membership functions, 20 Mamdani rules, and discrete centroid defuzzification with a Flutter Material 3 mobile app and PostgreSQL database, the system delivers transparent, highly accurate, and explainable academic performance analytics.
