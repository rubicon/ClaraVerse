import { Link2 } from 'lucide-react';
import { Typography, Alert } from '@/components/design-system';
import type { DeviceInfo } from '../MCPOnboarding';
import './AuthStep.css';

export interface AuthStepProps {
  initialCode?: string;
  userEmail?: string;
  onAuthorized: (deviceInfo: DeviceInfo) => void;
}

export const AuthStep = ({ onAuthorized }: AuthStepProps) => {
  // In OSS mode, device authorization is handled locally
  // Auto-authorize with local device info
  const handleAutoAuthorize = () => {
    onAuthorized({
      device_id: 'local',
      platform: navigator.platform || 'unknown',
      client_version: '1.0.0',
    });
  };

  return (
    <div className="auth-step">
      <div className="step-header">
        <div className="step-icon-wrapper">
          <Link2 size={24} />
        </div>
        <Typography variant="h4" weight="semibold" className="step-title">
          Connect Device
        </Typography>
        <Typography variant="sm" className="step-subtitle">
          In self-hosted mode, your device is authorized automatically.
        </Typography>
      </div>

      <button
        type="button"
        onClick={handleAutoAuthorize}
        className="auth-step-auto-btn"
        style={{
          width: '100%',
          padding: '12px',
          borderRadius: '8px',
          border: 'none',
          background: 'var(--color-primary, #6366f1)',
          color: 'white',
          fontWeight: 600,
          cursor: 'pointer',
          marginTop: '16px',
        }}
      >
        Continue
      </button>

      <Alert
        variant="info"
        message="This device will be connected to your local ClaraVerse instance."
        className="auth-warning"
      />
    </div>
  );
};
