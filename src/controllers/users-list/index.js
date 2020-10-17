module.exports = (req, res) => {
  return res.emiter({
    res,
    code: 200,
    data: {
      res: 'users-list',
      when: req.requestTime,
      emiter: typeof res.emiter
    },
  })
}