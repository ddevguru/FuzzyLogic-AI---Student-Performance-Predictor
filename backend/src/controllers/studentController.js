const dbStore = require('../services/dbStore');

const getProfile = async (req, res, next) => {
  try {
    const profile = await dbStore.getStudentProfile(req.user.id);
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Student profile not found.',
      });
    }

    res.json({
      success: true,
      profile,
    });
  } catch (err) {
    next(err);
  }
};

const updateProfile = async (req, res, next) => {
  try {
    const { rollNumber, course, semester, department } = req.body;

    const profile = await dbStore.upsertStudentProfile({
      userId: req.user.id,
      rollNumber,
      course,
      semester: parseInt(semester, 10),
      department,
    });

    res.json({
      success: true,
      message: 'Profile updated successfully.',
      profile,
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getProfile,
  updateProfile,
};
