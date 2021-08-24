const Scorer = {
  round: "1",
  useLocalScoring: false,
  localScores: [],

  disconnected() {
    this.useLocalScoring = true
  },

  reconnected() {
    for (const score of this.localScores) {
      this.pushEvent('set-round-score', score)
    }
    this.pushEvent('set-round', {round: this.round})
    this.localScores = []
    this.useLocalScoring = false
  },

  mounted() {
    document.querySelectorAll('.round-tab').forEach(roundTab => {
      roundTab.addEventListener('click', () => {
        this.round = roundTab.dataset.round
      })
    })
    document.querySelectorAll('.scorer').forEach(scorer => {
      scorer.querySelectorAll('button').forEach(btn => {
        btn.addEventListener('click', () => {
          if (this.useLocalScoring) {
            this.localScores.push({hole: btn.dataset.hole, score: btn.dataset.score, round: btn.dataset.round})
            document.querySelector(`.score-input[data-hole="${btn.dataset.hole}"]`).innerHTML = btn.dataset.score
            const scoreInput = document.querySelector(`.cell[data-hole="${btn.dataset.hole}"]`)
            const score = +btn.dataset.score - +scoreInput.dataset.par
            if (score > 0) {
              scoreInput.innerHTML = `+${score}`
              scoreInput.style.color = "black"
            } else if (score === 0) {
              scoreInput.innerHTML = "E"
              scoreInput.style.color = "green"
            } else {
              scoreInput.innerHTML = score
              scoreInput.style.color = "#a80000"
            }
          }
        })
      })
    })
  },

  updated() {
    // console.log("Updated", this)
  }
}

export default Scorer
