from pydantic import BaseModel
from enum import Enum

class ShotType(Enum):
    ExtremeLongShot = 'Extreme Long Shot'
    LongShot = 'Long Shot'
    FullShot = 'Full Shot'
    MediumLongShot = 'Medium Long Shot'
    MediumShot = 'Medium Shot'
    MediumCloseUp = 'Medium Close-Up'
    CloseUp = 'Close-Up'
    Chocker = 'Chocker'
    ExtremeCloseUp = 'Extreme Close-Up'
    No = 'No'

class ShotAngleAndPosition(Enum):
    LowAngle = 'Low Angle'
    EyeLevel = 'Eye Level'
    HighAngle = 'High Angle'
    Tilt = 'Tilt'
    OverTheSholderShot = 'Over-the-Sholder Shot'
    TopShot = 'Top Shot'
    No = 'No'

class CameraMovement(Enum):
    NoMovement = 'No Movement'
    Panning = 'Panning'
    Tilting = 'Tilting'
    WhipPan = 'Whip Pan'
    Slider = 'Slider'
    VerticalSlider = 'Vertical Slider'
    Tracking = 'Tracking'
    CrabShot = 'Crab Shot'
    SholderMountMovement = 'Sholder Mount Movement'
    GimbalMovement = 'Gimbal Movement'
    WireShot = 'Wire Shot'
    DollyShot = 'Dolly Shot'
    ZoomIn = 'Zoom In'
    ZoomOut = 'Zoom Out'
    VertigoShot = 'Vertigo Shot'
    ArcMovement = 'Arc Movement'
    BulletTime = 'Bullet Time'
    CameraShakerMovement = 'Camera Shaker Movement'
    ComplexMovement = 'Complex Movement'

class Filming(BaseModel):
    shotType: ShotType
    shotAngleAndPosition: ShotAngleAndPosition
    cameraMovement: CameraMovement

class DramaticAction(BaseModel):
    Gesture: str
    FacialExpression: str
    Movement: str
    Costume: str

class Editing(BaseModel):
    Transition: str

class Action(BaseModel):
    scene: int = 1
    action: int = 1
    description: str
    dramaticAction: DramaticAction
    filming: Filming
    editing: Editing

class AnalyseStructure(BaseModel):
    actions: Action
