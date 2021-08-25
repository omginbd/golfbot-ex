const Scorer = {
  round: "1",
  useLocalScoring: false,

  disconnected() {
    this.useLocalScoring = true
  },

  reconnected() {
    window.localforage.getItem('pending-scores', (err, pendingScores) => {
      this.pushEvent('set-round', {round: this.round})
      this.useLocalScoring = false

      if (!pendingScores || err) return
      for (const score of pendingScores) {
        this.pushEvent('set-round-score', score)
      }
      window.localforage.removeItem('pending-scores')
    })
  },

  mounted() {
    // sync any pending scores
    window.localforage.getItem('pending-scores', (err, pendingScores) => {
      try {
        if (!pendingScores || err) return
        for (const score of pendingScores) {
          this.pushEvent('set-round-score', score)
        }
      } catch (e) {
      } finally {
        window.localforage.removeItem('pending-scores')
      }
    })

    document.querySelectorAll('.round-tab').forEach(roundTab => {
      roundTab.addEventListener('click', () => {
        this.round = roundTab.dataset.round
      })
    })
    document.querySelectorAll('.scorer').forEach(scorer => {
      scorer.querySelectorAll('button').forEach(btn => {
        btn.addEventListener('click', () => {
          if (this.useLocalScoring) {
            window.localforage.getItem('pending-scores', (err, pendingScores) => {
              pendingScores = pendingScores || []
              pendingScores.push({hole: btn.dataset.hole, score: btn.dataset.score, round: btn.dataset.round})
              window.localforage.setItem('pending-scores', pendingScores)
            })
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
}

export default Scorer
