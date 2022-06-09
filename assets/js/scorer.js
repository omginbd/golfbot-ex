const Scorer = {
  reconnected() {
    window.localforage.iterate((score, holeKey, _i) => {
      try {
        this.pushEvent('set-round-score', score)
      } catch (e) {
      } finally {
        window.localforage.removeItem(holeKey)
      }
    })
  },

  mounted() {
    // sync any pending scores
    window.localforage.iterate((score, holeKey, _i) => {
      try {
        this.pushEvent('set-round-score', score)
      } catch (e) {
      } finally {
        window.localforage.removeItem(holeKey)
      }
    })
    document.querySelectorAll('.scorer').forEach(scorer => {
      scorer.querySelectorAll('button').forEach(btn => {
        btn.addEventListener('click', () => {
          const score = { hole: btn.dataset.hole, score: btn.dataset.score, round: btn.dataset.round, gif: true }
          if (liveSocket.isConnected()) {
            this.pushEvent('set-round-score', score)
          } else {
            score.gif = false
            const holeKey = `${btn.dataset.hole}-${btn.dataset.round}`
            window.localforage.getItem(holeKey, (err, existingScore) => {
              if (err) return
              window.localforage.setItem(holeKey, score)
            })
          }
          document.querySelector(`.score-input[data-hole="${btn.dataset.hole}"]`).innerHTML = btn.dataset.score
          const scoreInput = document.querySelector(`.cell[data-hole="${btn.dataset.hole}"]`)
          const scoreValue = +btn.dataset.score - +scoreInput.dataset.par
          if (scoreValue > 0) {
            scoreInput.innerHTML = `+${scoreValue}`
            scoreInput.style.color = "black"
          } else if (scoreValue === 0) {
            scoreInput.innerHTML = "E"
            scoreInput.style.color = "green"
          } else {
            scoreInput.innerHTML = scoreValue
            scoreInput.style.color = "#a80000"
          }
        })
      })
    })
  },
}

export default Scorer
